"
I check how roads, highways and rivers on the edges between plots change the dispersal of boars: highways stop them, roads stop half and kill some, and rivers attract them.
"
Class {
	#name : 'BBLinearFeatureTest',
	#superclass : 'BBTestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'helpers' }
BBLinearFeatureTest >> modelWithFullMiddlePlotAndRightEdge: anEdgeCode [
	"Three forest plots in a row, where only the middle one has boars, and it is full. The edge between the middle and the right plot carries anEdgeCode, listed on both plots as in the plot table"

	| model |
	model := self
		         modelWithPlotRows: {
				         (self plotRowAt: 1 @ 1 with: #(  )).
				         (self plotRowAt: 1 @ 2 with: { ('edgeSE' -> anEdgeCode) }).
				         (self plotRowAt: 1 @ 3 with: { ('edgeNW' -> anEdgeCode) }) }
		         coverRows: ((1 to: 3) collect: [ :column |
				          self
					          coverRowAt: 1 @ column
					          with: { ('coverForest_90' -> '1') } ]).
	(model cellAt: 1 at: 1) boars: 0.
	(model cellAt: 1 at: 2) boars: 33.
	(model cellAt: 1 at: 3) boars: 0.
	^ model
]

{ #category : 'tests' }
BBLinearFeatureTest >> testAnEdgeListedOnBothPlotsGetsOneFeatureOfEachType [

	| model middle right |
	model := self modelWithFullMiddlePlotAndRightEdge: 'RW'.
	middle := model cellAt: 1 at: 2.
	right := model cellAt: 1 at: 3.

	self assert: model links size equals: 2.
	self
		assert:
			((middle featuresTowards: right) collect: [ :each | each class ])
				asSet
		equals: {
				BBRoad.
				BBRiver } asSet.
	self
		assert:
			((right featuresTowards: middle) collect: [ :each | each class ])
				asSet
		equals: {
				BBRoad.
				BBRiver } asSet.
	self assert:
		((model cellAt: 1 at: 1) featuresTowards: middle) isEmpty
]

{ #category : 'tests' }
BBLinearFeatureTest >> testFeaturesOnTheSameEdgeShareTheirCorners [

	| model road river |
	model := self modelWithFullMiddlePlotAndRightEdge: 'RW'.
	road := (model allEntitiesOfClass: BBRoad) first.
	river := (model allEntitiesOfClass: BBRiver) first.

	self assert: road ends asSet equals: river ends asSet.
	self assert: (model allEntitiesOfClass: BBNode) size equals: 2
]

{ #category : 'tests' }
BBLinearFeatureTest >> testHighwayTurnsBoarsBackToOtherEdges [
	"The boars stopped by the highway leave through the free edge instead"

	| model |
	model := self modelWithFullMiddlePlotAndRightEdge: 'H'.
	model disperseBoarsByDensity.

	self assert: (model cellAt: 1 at: 1) boars closeTo: 3.3.
	self assert: (model cellAt: 1 at: 3) boars equals: 0.
	self assert: model totalBoars closeTo: 33
]

{ #category : 'tests' }
BBLinearFeatureTest >> testRiverAlongTwoEdgesIsOneLineThroughTheirCommonCorner [
	"The river follows the edge between the plots of row 1, then turns down between the plots of column 2. Its two segments meet at the corner the three plots share, even though different plots list them"

	| model segments |
	model := self
		         modelWithPlotRows: {
				         (self plotRowAt: 1 @ 1 with: { ('edgeNE' -> 'W') }).
				         (self plotRowAt: 1 @ 2 with: {
						          ('edgeSW' -> 'W').
						          ('edgeS' -> 'W') }).
				         (self plotRowAt: 2 @ 1 with: #(  )).
				         (self plotRowAt: 2 @ 2 with: { ('edgeN' -> 'W') }) }
		         coverRows: ({
				          (1 @ 1).
				          (1 @ 2).
				          (2 @ 1).
				          (2 @ 2) } collect: [ :each |
				          self coverRowAt: each with: #(  ) ]).
	segments := model allEntitiesOfClass: BBRiver.

	self assert: segments size equals: 2.
	self
		assert: (segments first ends intersection: segments last ends) size
		equals: 1.
	self assert: (model allEntitiesOfClass: BBNode) size equals: 3
]

{ #category : 'tests' }
BBLinearFeatureTest >> testRiverAttractsBoars [
	"A plot on a river is twice as attractive, and rivers do not stop boars"

	| model |
	model := self modelWithFullMiddlePlotAndRightEdge: 'W'.
	model disperseBoarsByDensity.

	self assert: (model cellAt: 1 at: 1) boars closeTo: 1.1.
	self assert: (model cellAt: 1 at: 3) boars closeTo: 2.2
]

{ #category : 'tests' }
BBLinearFeatureTest >> testRoadStopsHalfTheBoarsAndKillsSomeOfTheOthers [
	"Of the 1.65 boars heading right, half are stopped and go left, and 5 % of the other half die on the road"

	| model road |
	model := self modelWithFullMiddlePlotAndRightEdge: 'R'.
	road := model links first.
	model disperseBoarsByDensity.

	self assert: (model cellAt: 1 at: 1) boars closeTo: 1.65 + 0.825.
	self assert: (model cellAt: 1 at: 3) boars closeTo: 0.825 * 0.95.
	self assert: road collisions closeTo: 0.825 * 0.05.
	self assert: model totalBoars closeTo: 33 - (0.825 * 0.05)
]

{ #category : 'tests' }
BBLinearFeatureTest >> testRoadsKillSomeOfTheBoarsLivingBesideThem [
	"A road kills 0.5 % of the boars of the plot that holds it, the one with the lower id"

	| model road |
	model := self modelWithFullMiddlePlotAndRightEdge: 'R'.
	(model cellAt: 1 at: 3) boars: 20.
	road := model links first.
	model killBoarsOnRoads.

	self assert: (model cellAt: 1 at: 2) boars closeTo: 33 * 0.995.
	self assert: (model cellAt: 1 at: 3) boars equals: 20.
	self assert: road collisions closeTo: 33 * 0.005
]

{ #category : 'tests' }
BBLinearFeatureTest >> testWithoutFeaturesBoarsSplitEvenly [

	| model |
	model := self modelWithFullMiddlePlotAndRightEdge: ''.
	model disperseBoarsByDensity.

	self assert: (model cellAt: 1 at: 1) boars closeTo: 1.65.
	self assert: (model cellAt: 1 at: 3) boars closeTo: 1.65
]
