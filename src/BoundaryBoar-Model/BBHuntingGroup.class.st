"
I am a local hunting group (ACCA or hunting society), which hunts on a hunting unit. Every year I organize driven hunts on the huntable plots of my unit, more of them every year until 2018, and on the plots with the most boars.

## Responsibility:

- Stop my hunts on plots where hunting is no longer possible.
- Move my least successful hunts to the huntable plots with the most boars.
- Keep the number of my hunts at a share of my huntable plots that grows from 2.5 % in 1990 to 90 % in 2018, all three parameters of my class.

## Collaborators:

- `BBHuntingUnit`: my unit, which knows me.
- `BBDrivenHunt`: my hunts, which stand on plots of my unit.
- `BBPlot` tells whether it is huntable.

## Public API and Key Messages

- `organizeHuntsIn: aYear` makes my yearly decisions.
- `organizeHuntOn: aPlot` organizes one hunt.
- `hunts` and `huntablePlots`.

```
group := (model cellAt: 1 at: 1) huntingUnit huntingGroup.
group organizeHuntsIn: 2004.
group hunts size. ""about 46 % of the huntable plots of the unit""
```

### Implementation Points

Plots with the same number of boars, and hunts with the same bag, keep the order of the plots.
"
Class {
	#name : 'BBHuntingGroup',
	#superclass : 'CMAgent',
	#instVars : [
		'huntingUnit'
	],
	#classInstVars : [
		'initialHuntShare',
		'finalHuntShare',
		'movedHuntShare'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBHuntingGroup class >> finalHuntShare [
	"The share of its huntable plots that a hunting group hunts from 2018"

	<parameterFloatMin: 0 max: 1 default: 0.9>
	^ finalHuntShare
]

{ #category : 'parameters' }
BBHuntingGroup class >> finalHuntShare: aNumber [

	finalHuntShare := aNumber
]

{ #category : 'parameters' }
BBHuntingGroup class >> initialHuntShare [
	"The share of its huntable plots that a hunting group hunted in 1990"

	<parameterFloatMin: 0 max: 1 default: 0.025>
	^ initialHuntShare
]

{ #category : 'parameters' }
BBHuntingGroup class >> initialHuntShare: aNumber [

	initialHuntShare := aNumber
]

{ #category : 'parameters' }
BBHuntingGroup class >> movedHuntShare [
	"The share of its hunts, the least successful, that a hunting group moves each year to plots with more boars"

	<parameterFloatMin: 0 max: 1 default: 0.1>
	^ movedHuntShare
]

{ #category : 'parameters' }
BBHuntingGroup class >> movedHuntShare: aNumber [

	movedHuntShare := aNumber
]

{ #category : 'hunting' }
BBHuntingGroup >> bestPlotsToHunt: aNumber [
	"Answer at most aNumber huntable plots where I do not hunt yet, those with the most boars first"

	| hunted free |
	hunted := self hunts collect: [ :each | each cell ].
	free := (self huntablePlots reject: [ :each | hunted includes: each ])
		        sorted: [ :a :b | a boars >= b boars ].
	^ free first: (aNumber min: free size)
]

{ #category : 'accessing' }
BBHuntingGroup >> huntablePlots [

	^ huntingUnit components select: [ :each | each isHuntable ]
]

{ #category : 'accessing' }
BBHuntingGroup >> huntingUnit [

	^ huntingUnit
]

{ #category : 'accessing' }
BBHuntingGroup >> huntingUnit: aHuntingUnit [

	huntingUnit := aHuntingUnit
]

{ #category : 'accessing' }
BBHuntingGroup >> hunts [
	"Answer the driven hunts I organize"

	^ (self cormasModel allEntitiesOfClass: BBDrivenHunt) select: [ :each |
		  each organizer == self ]
]

{ #category : 'hunting' }
BBHuntingGroup >> keepHunts: aNumber [
	"Stop the least successful hunts, or organize new ones on the plots with the most boars, to have aNumber of hunts"

	| hunts |
	hunts := self hunts.
	hunts size > aNumber ifTrue: [
			((hunts sorted: [ :a :b | a boarsKilled <= b boarsKilled ]) first:
				 hunts size - aNumber) do: [ :each | each delete ] ].
	hunts size < aNumber ifTrue: [
			(self bestPlotsToHunt: aNumber - hunts size) do: [ :each |
				self organizeHuntOn: each ] ]
]

{ #category : 'hunting' }
BBHuntingGroup >> moveLeastSuccessfulHunts [
	"Move the hunts that killed the fewest boars last year to the huntable plots with the most boars where I do not hunt yet"

	| hunts least plots |
	hunts := self hunts.
	hunts isEmpty ifTrue: [ ^ self ].
	least := (hunts sorted: [ :a :b | a boarsKilled <= b boarsKilled ])
		         first: (hunts size * self class movedHuntShare) ceiling.
	plots := self bestPlotsToHunt: least size.
	1 to: (least size min: plots size) do: [ :index |
	(least at: index) moveTo: (plots at: index) ]
]

{ #category : 'hunting' }
BBHuntingGroup >> organizeHuntOn: aPlot [

	^ (self cormasModel newEntity: BBDrivenHunt locatedAt: aPlot)
		  organizer: self;
		  yourself
]

{ #category : 'hunting' }
BBHuntingGroup >> organizeHuntsIn: aYear [
	"Each year, stop the hunts where hunting is no longer possible, move the least successful ones to the plots with the most boars, and hunt more plots every year until 2018"

	| huntable |
	huntable := self huntablePlots.
	(self hunts reject: [ :each | huntable includes: each cell ]) do: [
		:each | each delete ].
	self moveLeastSuccessfulHunts.
	self keepHunts: (self targetHuntsIn: aYear among: huntable size)
]

{ #category : 'hunting' }
BBHuntingGroup >> targetHuntsIn: aYear among: aNumberOfHuntablePlots [
	"The share of the huntable plots that are hunted grows steadily from 1990 to 2018, and then stays the same"

	| share |
	share := self class finalHuntShare.
	aYear < 2018 ifTrue: [
			share := self class initialHuntShare
			         +
			         (aYear - 1990 * (share - self class initialHuntShare) / 28) ].
	^ (share * aNumberOfHuntablePlots) rounded
]
