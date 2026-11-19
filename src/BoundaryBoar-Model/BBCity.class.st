"
I am a municipality, which manages a city territory. When the residents of my neighbourhood associations complain, from 2019, I choose each year the policy that keeps the most boars out of town next year, net of its cost: cut access to household waste, cut the feeding of boars by residents, or brush-cut the most vegetated town plots. I also decide whether hunting is allowed on my territory.

## Responsibility:

- Manage my `BBCityTerritory`.
- Allow or ban hunting on my territory.
- Choose and apply my policies against boars, by quarters, each costing more than the last.

## Collaborators:

- `BBCityTerritory`: my territory, which knows me.
- `BBPlot` asks me whether hunting is allowed on it.

## Public API and Key Messages

- `name` answers the name of my territory, such as 'MONTPELLIER'.
- `isHuntingAllowed` and `banHunting`.
- `decidePolicy` makes my yearly choice, and `applyFoodPolicies` sets waste and feeding on my plots.
- `wastePolicy`, `feedingPolicy` and `brushcuttingCampaigns` answer what I have done.
- The weight of costs and the brush-cutting settings are parameters of my class.

```
(model cellAt: 9 at: 12) city banHunting.
```
"
Class {
	#name : 'BBCity',
	#superclass : 'CMAgent',
	#instVars : [
		'territory',
		'isHuntingAllowed',
		'wastePolicy',
		'feedingPolicy',
		'brushcuttingCampaigns'
	],
	#classInstVars : [
		'policyCostWeight',
		'brushcuttingCut',
		'brushcuttingThreshold',
		'brushcuttingShare'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBCity class >> brushcuttingCut [
	"The share of urban tree cover that one brush-cutting campaign turns into grass"

	<parameterFloatMin: 0 max: 1 default: 0.05>
	^ brushcuttingCut
]

{ #category : 'parameters' }
BBCity class >> brushcuttingCut: aNumber [

	brushcuttingCut := aNumber
]

{ #category : 'parameters' }
BBCity class >> brushcuttingShare [
	"The share of the town plots needing brush-cutting that a campaign covers, the most vegetated first"

	<parameterFloatMin: 0 max: 1 default: 0.2>
	^ brushcuttingShare
]

{ #category : 'parameters' }
BBCity class >> brushcuttingShare: aNumber [

	brushcuttingShare := aNumber
]

{ #category : 'parameters' }
BBCity class >> brushcuttingThreshold [
	"The urban vegetation score above which a town plot needs brush-cutting"

	<parameterFloatMin: 0 max: 1 default: 0.5>
	^ brushcuttingThreshold
]

{ #category : 'parameters' }
BBCity class >> brushcuttingThreshold: aNumber [

	brushcuttingThreshold := aNumber
]

{ #category : 'parameters' }
BBCity class >> policyCostWeight [
	"How much the cost of a policy counts against the boars it keeps out of town"

	<parameterFloatMin: 0 max: 1 default: 0.05>
	^ policyCostWeight
]

{ #category : 'parameters' }
BBCity class >> policyCostWeight: aNumber [

	policyCostWeight := aNumber
]

{ #category : 'parameters' }
BBCity class >> policyCosts [
	"The cost of reaching each level of a waste or feeding policy"

	^ {
		  (0.25 -> 1).
		  (0.5 -> 2).
		  (0.75 -> 4).
		  (1 -> 8) } asDictionary
]

{ #category : 'policies' }
BBCity >> adopt: aPolicy toBrushcut: somePlots [

	aPolicy = #waste ifTrue: [ ^ self raiseWastePolicy ].
	aPolicy = #feeding ifTrue: [ ^ self raiseFeedingPolicy ].
	brushcuttingCampaigns := brushcuttingCampaigns + 1.
	somePlots do: [ :each |
		each landCover brushCutBy: self class brushcuttingCut ]
]

{ #category : 'policies' }
BBCity >> applyFoodPolicies [

	self plots do: [ :each |
			each
				limitWasteBy: wastePolicy;
				limitFeedingBy: feedingPolicy ]
]

{ #category : 'hunting' }
BBCity >> banHunting [
	"Forbid hunting on my territory, for good"

	isHuntingAllowed := false
]

{ #category : 'policies' }
BBCity >> brushcuttingCampaigns [

	^ brushcuttingCampaigns
]

{ #category : 'policies' }
BBCity >> changeOf: aPolicy toBrushcut: somePlots [
	"Answer a block that changes a plot as aPolicy would"

	aPolicy = #waste ifTrue: [
		^ [ :plot | plot limitWasteBy: (wastePolicy + 0.25 min: 1) ] ].
	aPolicy = #feeding ifTrue: [
		^ [ :plot | plot limitFeedingBy: (feedingPolicy + 0.25 min: 1) ] ].
	^ [ :plot |
		  (somePlots includes: plot) ifTrue: [
			  plot landCover brushCutBy: self class brushcuttingCut ] ]
]

{ #category : 'policies' }
BBCity >> costOf: aPolicy [

	aPolicy = #waste ifTrue: [
		^ self class policyCosts at: (wastePolicy + 0.25 min: 1) ].
	aPolicy = #feeding ifTrue: [
		^ self class policyCosts at: (feedingPolicy + 0.25 min: 1) ].
	^ 0
]

{ #category : 'policies' }
BBCity >> decidePolicy [
	"When residents complain, choose the policy that keeps the most boars out of town next year, net of its cost: cut waste, cut feeding, or brush-cut the most vegetated town plots. Do nothing if no policy does better than nothing"

	| policies toBrushcut baseline best bestScore |
	self hasDissatisfiedResidents ifFalse: [ ^ self ].
	toBrushcut := self plotsToBrushcut.
	policies := OrderedCollection new.
	wastePolicy < 1 ifTrue: [ policies add: #waste ].
	feedingPolicy < 1 ifTrue: [ policies add: #feeding ].
	toBrushcut isEmpty ifFalse: [ policies add: #brushcutting ].
	baseline := self projectedUrbanBoarsAfter: [ :plot |  ].
	best := nil.
	bestScore := 0.
	policies do: [ :each |
			| score |
			score := baseline - (self projectedUrbanBoarsAfter:
				          (self changeOf: each toBrushcut: toBrushcut))
			         - (self class policyCostWeight * (self costOf: each)).
			score > bestScore ifTrue: [
					best := each.
					bestScore := score ] ].
	best ifNotNil: [ self adopt: best toBrushcut: toBrushcut ]
]

{ #category : 'policies' }
BBCity >> feedingPolicy [
	"Answer how much I have cut the feeding of boars by residents, from 0 to 1 by quarters"

	^ feedingPolicy
]

{ #category : 'policies' }
BBCity >> hasDissatisfiedResidents [

	^ self plots anySatisfy: [ :plot |
		  plot associations anySatisfy: [ :each | each isDissatisfied ] ]
]

{ #category : 'initialization' }
BBCity >> initialize [

	super initialize.
	isHuntingAllowed := true.
	wastePolicy := 0.
	feedingPolicy := 0.
	brushcuttingCampaigns := 0
]

{ #category : 'accessing' }
BBCity >> isHuntingAllowed [

	^ isHuntingAllowed
]

{ #category : 'accessing' }
BBCity >> name [

	^ territory name
]

{ #category : 'policies' }
BBCity >> plots [

	^ territory components
]

{ #category : 'policies' }
BBCity >> plotsToBrushcut [
	"Answer the town plots where vegetation helps boars most, a share of those above the threshold, at least one if there are any"

	| candidates |
	candidates := (self plots select: [ :each |
			               each urbanFraction > 0.3 and: [
				               each landCover urbanVegetationScore
				               > self class brushcuttingThreshold ] ]) sorted: [
		              :a
		              :b |
		              a landCover urbanVegetationScore
		              >= b landCover urbanVegetationScore ].
	candidates isEmpty ifTrue: [ ^ candidates ].
	^ candidates first:
		  ((candidates size * self class brushcuttingShare) ceiling max: 1)
]

{ #category : 'policies' }
BBCity >> projectedUrbanBoarsAfter: aChangeBlock [

	^ self plots
		  inject: 0
		  into: [ :sum :each |
		  sum + (each projectedUrbanBoarsAfter: aChangeBlock) ]
]

{ #category : 'policies' }
BBCity >> raiseFeedingPolicy [

	feedingPolicy := feedingPolicy + 0.25 min: 1
]

{ #category : 'policies' }
BBCity >> raiseFeedingPolicyTo: aLevel [

	feedingPolicy := feedingPolicy max: aLevel
]

{ #category : 'policies' }
BBCity >> raiseWastePolicy [

	wastePolicy := wastePolicy + 0.25 min: 1
]

{ #category : 'policies' }
BBCity >> raiseWastePolicyTo: aLevel [

	wastePolicy := wastePolicy max: aLevel
]

{ #category : 'accessing' }
BBCity >> territory [

	^ territory
]

{ #category : 'accessing' }
BBCity >> territory: aCityTerritory [

	territory := aCityTerritory
]

{ #category : 'policies' }
BBCity >> wastePolicy [
	"Answer how much I have cut access to household waste, from 0 to 1 by quarters"

	^ wastePolicy
]
