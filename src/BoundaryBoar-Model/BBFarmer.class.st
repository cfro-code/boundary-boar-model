"
I am a farmer, who farms part of the farmland of one plot. Boars that live in the farmland damage my crop. From 2019, I protect it with fences, from the hunting federation or my own, and by hunting on my plot.

## Responsibility:

- Measure each year the damage boars do to my crop, and remember the last three years.
- Ask for temporary fences after serious damage, install permanent ones after heavy damage if I can afford them, and set up a stand when boars threaten my crop heavily.
- Expose the boars of my part of the farmland to the stands I organize.

## Collaborators:

- `BBPlot`: my plot, which tells how many of its boars live in its farmland, and how many could.
- `BBHuntingFederation` gives me temporary fences.
- `BBStand`: the stands I set up.

## Public API and Key Messages

- `assessDamage` measures the damage of the year; `damage` answers it, from 0 to 1.
- `needsTemporaryFences`, `considerPermanentFences` and `considerStand` are my yearly decisions.
- `surface` answers the fraction of my plot I farm.
- My subclasses give my `crop`, my damage sensitivity and my probability of affording permanent fences, as parameters of their class. The efficiency of fences and the number of farmers per plot are parameters of my class.

```
farmer := (model cellAt: 8 at: 15) farmers first.
farmer assessDamage.
farmer damage. ""from 0 to 1""
```

## Internal Representation

- `surface` is a fraction of the area of my plot.
- `damage` is the damage of the last year, and `damageHistory` the last three, the latest last.
- `canInstallPermanentFences` is drawn once when I am created.

### Implementation Points

Damage compares the boars in my farmland with the most it can hold, which, as in the original model, divides by the habitat potential of the plot rather than its habitat quality, and ignores acorns. The original also reduced damage with the stands of the farmer, but stands are removed at the start of each year, before damage is measured, so this had no effect and is left out. Whether I can afford permanent fences is drawn at random, where the original compared my id with the probability.
"
Class {
	#name : 'BBFarmer',
	#superclass : 'CMAgent',
	#instVars : [
		'surface',
		'hasTemporaryFences',
		'hasPermanentFences',
		'canInstallPermanentFences',
		'areStandsAuthorized',
		'damage',
		'damageHistory'
	],
	#classInstVars : [
		'damageSensitivity',
		'fencingProbability',
		'permanentFenceEfficiency',
		'temporaryFenceEfficiency',
		'maximumFarmersPerPlot',
		'minimumCropShare'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBFarmer class >> crop [
	"Answer the crop I grow, as named in BBLandCover>>agriculturalShareOf:"

	^ self subclassResponsibility
]

{ #category : 'aspects' }
BBFarmer class >> cropColor [

	^ self subclassResponsibility
]

{ #category : 'parameters' }
BBFarmer class >> damageSensitivity: aNumber [

	damageSensitivity := aNumber
]

{ #category : 'parameters' }
BBFarmer class >> fencingProbability: aNumber [

	fencingProbability := aNumber
]

{ #category : 'parameters' }
BBFarmer class >> maximumFarmersPerPlot [
	"The number of farmers on a plot covered with farmland"

	<parameterIntegerMin: 1 max: 10 default: 3>
	^ maximumFarmersPerPlot
]

{ #category : 'parameters' }
BBFarmer class >> maximumFarmersPerPlot: anInteger [

	maximumFarmersPerPlot := anInteger
]

{ #category : 'parameters' }
BBFarmer class >> minimumCropShare [
	"The smallest share of the farmland of a plot that a crop needs to have its farmers"

	<parameterFloatMin: 0 max: 1 default: 0.05>
	^ minimumCropShare
]

{ #category : 'parameters' }
BBFarmer class >> minimumCropShare: aNumber [

	minimumCropShare := aNumber
]

{ #category : 'parameters' }
BBFarmer class >> permanentFenceEfficiency [
	"The share of the damage that permanent fences prevent"

	<parameterFloatMin: 0 max: 1 default: 0.9>
	^ permanentFenceEfficiency
]

{ #category : 'parameters' }
BBFarmer class >> permanentFenceEfficiency: aNumber [

	permanentFenceEfficiency := aNumber
]

{ #category : 'parameters' }
BBFarmer class >> temporaryFenceEfficiency [
	"The share of the damage that temporary fences prevent"

	<parameterFloatMin: 0 max: 1 default: 0.3>
	^ temporaryFenceEfficiency
]

{ #category : 'parameters' }
BBFarmer class >> temporaryFenceEfficiency: aNumber [

	temporaryFenceEfficiency := aNumber
]

{ #category : 'aspects' }
BBFarmer >> aspectDamage: look [
	"Red, darker the more damage boars did to my crop last year"

	<aspect>
	self aspectDefault: look.
	look
		colorShadeOf: Color red
		forValue: damage
		from: 0
		to: 1
]

{ #category : 'aspects' }
BBFarmer >> aspectDefault: look [
	"A small square in the color of my crop"

	<aspect>
	look
		color: self class cropColor;
		shape: #square;
		size: 0.25
]

{ #category : 'aspects' }
BBFarmer >> aspectFences: look [
	"Black with permanent fences, grey with temporary ones, white without"

	<aspect>
	self aspectDefault: look.
	look color: (hasPermanentFences
			 ifTrue: [ Color black ]
			 ifFalse: [
					 hasTemporaryFences
						 ifTrue: [ Color gray ]
						 ifFalse: [ Color white ] ])
]

{ #category : 'damage' }
BBFarmer >> assessDamage [
	"Measure the damage of the year against the most boars could do, and remember the last three years. Without farmland that boars could use, the damage stays as it was"

	| maximum |
	maximum := self maximumBoarPressure.
	maximum > 0 ifTrue: [
			damage := (self boarPressure * (1 - self protection) max: 0)
			          / maximum min: 1 ].
	damageHistory add: damage.
	damageHistory size > 3 ifTrue: [ damageHistory removeFirst ]
]

{ #category : 'damage' }
BBFarmer >> boarPressure [
	"Answer how much the boars in the farmland of my plot threaten my crop"

	^ self cell farmlandBoars * self class damageSensitivity * surface
	  * self cell agriculturalUseFactor
]

{ #category : 'protecting crops' }
BBFarmer >> boarsExposedToStands [
	"Answer the boars that a stand I organize can shoot: those in my part of the farmland"

	^ self cell farmlandBoars * surface
]

{ #category : 'protecting crops' }
BBFarmer >> considerPermanentFences [
	"Without temporary fences, install permanent ones with a probability that grows with the damage of the last three years, if I can afford them"

	| meanDamage probability |
	hasTemporaryFences ifTrue: [ ^ self ].
	meanDamage := (damageHistory sum: [ :each | each ])
	              / damageHistory size.
	probability := meanDamage - 0.7 / 0.3 min: 1 max: 0.
	(self random < probability and: [ canInstallPermanentFences ])
		ifTrue: [ self installPermanentFences ]
]

{ #category : 'protecting crops' }
BBFarmer >> considerStand [
	"Hunt on my plot when boars threaten my crop heavily and I have no permanent fences"

	(areStandsAuthorized and: [
		 self isUnderHeavyPressure and: [ hasPermanentFences not ] ])
		ifTrue: [ self setUpStand ]
]

{ #category : 'accessing' }
BBFarmer >> damage [
	"Answer the damage of the last year, from 0 for none to 1 for the most boars can do"

	^ damage
]

{ #category : 'initialization' }
BBFarmer >> decideWhetherICanAffordPermanentFences [

	canInstallPermanentFences := self random
	                             < self class fencingProbability
]

{ #category : 'accessing' }
BBFarmer >> hasPermanentFences [

	^ hasPermanentFences
]

{ #category : 'accessing' }
BBFarmer >> hasTemporaryFences [

	^ hasTemporaryFences
]

{ #category : 'initialization' }
BBFarmer >> initialize [

	super initialize.
	hasTemporaryFences := false.
	hasPermanentFences := false.
	canInstallPermanentFences := false.
	areStandsAuthorized := true.
	damage := 0.
	damageHistory := OrderedCollection new
]

{ #category : 'protecting crops' }
BBFarmer >> installPermanentFences [

	hasPermanentFences := true
]

{ #category : 'protecting crops' }
BBFarmer >> installTemporaryFences [

	hasTemporaryFences := true
]

{ #category : 'damage' }
BBFarmer >> isUnderHeavyPressure [
	"Answer whether boars are above 70 % of the most they could be in my farmland, whatever my fences"

	| maximum |
	maximum := self maximumBoarPressure.
	^ maximum > 0 and: [ self boarPressure / maximum > 0.7 ]
]

{ #category : 'damage' }
BBFarmer >> maximumBoarPressure [

	^ self cell maximumFarmlandBoars * self class damageSensitivity
	  * surface
]

{ #category : 'protecting crops' }
BBFarmer >> needsTemporaryFences [
	"Answer whether I ask the hunting federation for temporary fences: I have no permanent ones, and boars did serious damage in one of the last three years"

	^ hasPermanentFences not and: [
		  damageHistory anySatisfy: [ :each | each > 0.5 ] ]
]

{ #category : 'damage' }
BBFarmer >> protection [
	"Answer the share of the damage that my fences prevent"

	| protection |
	protection := 0.
	hasPermanentFences ifTrue: [
		protection := protection + self class permanentFenceEfficiency ].
	hasTemporaryFences ifTrue: [
		protection := protection + self class temporaryFenceEfficiency ].
	^ protection min: 1
]

{ #category : 'protecting crops' }
BBFarmer >> removeTemporaryFences [

	hasTemporaryFences := false
]

{ #category : 'protecting crops' }
BBFarmer >> setUpStand [

	^ (self cormasModel newEntity: BBStand locatedAt: self cell)
		  organizer: self;
		  yourself
]

{ #category : 'accessing' }
BBFarmer >> surface [
	"Answer the fraction of the area of my plot that I farm"

	^ surface
]

{ #category : 'initialization' }
BBFarmer >> surface: aNumber [
	"Farm aNumber, a fraction of the area of my plot"

	surface := aNumber
]
