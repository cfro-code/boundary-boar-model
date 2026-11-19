"
I check the boars of a plot: where they live at the start, how they grow, and how they move to less crowded neighbours.
"
Class {
	#name : 'BBBoarTest',
	#superclass : 'BBTestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'helpers' }
BBBoarTest >> modelWithRowOfCovers: someCovers [
	"A model with one row of plots, the nth with the 1990 cover columns of the nth element"

	^ self
		  modelWithPlotRows: ((1 to: someCovers size) collect: [ :column |
				   self plotRowAt: 1 @ column with: #(  ) ])
		  coverRows: ((1 to: someCovers size) collect: [ :column |
				   self coverRowAt: 1 @ column with: (someCovers at: column) ])
]

{ #category : 'tests' }
BBBoarTest >> testBoarsDoNotGrowWithoutHabitat [

	| plot |
	plot := (self modelWithRowOfCovers: { { ('coverSea_90' -> '1') } })
		        cellAt: 1
		        at: 1.
	plot boars: 10.
	plot grow.

	self assert: plot boars equals: 10
]

{ #category : 'tests' }
BBBoarTest >> testBoarsGrowTowardsTheCarryingCapacity [
	"Theta-logistic growth with r = 0.5, K = 33 and theta = 1.5"

	| plot |
	plot := (self modelWithRowOfCovers: { { ('coverForest_90' -> '1') } })
		        cellAt: 1
		        at: 1.
	plot boars: 10.
	plot grow.

	self
		assert: plot boars
		closeTo: 10 + (0.5 * 10 * (1 - (10 / 33 raisedTo: 1.5)))
]

{ #category : 'tests' }
BBBoarTest >> testBoarsOnlyMoveToLessCrowdedPlots [
	"The half-full plot in the middle sends its dispersers to the plot a quarter full only, not to the plot three quarters full, which loses its own dispersers and receives none"

	| model crowded crowdedDispersers |
	model := self modelWithRowOfCovers: {
			         { ('coverForest_90' -> '1') }.
			         { ('coverForest_90' -> '1') }.
			         { ('coverForest_90' -> '1') } }.
	crowded := model cellAt: 1 at: 1.
	crowded boars: 24.75.
	(model cellAt: 1 at: 2) boars: 16.5.
	(model cellAt: 1 at: 3) boars: 8.25.
	crowdedDispersers := crowded densityDispersers.
	model disperseBoarsByDensity.

	self assert: crowdedDispersers > 0.
	self assert: crowded boars closeTo: 24.75 - crowdedDispersers.
	self assert: (model cellAt: 1 at: 3) boars > 8.25.
	self assert: model totalBoars closeTo: 49.5
]

{ #category : 'tests' }
BBBoarTest >> testBoarsStartInForestAndOpenLandAwayFromCities [
	"20 * 1.5 * 0.02 boars on a pure forest plot, and none on or next to a city"

	| model |
	model := self modelWithRowOfCovers: {
			         { ('coverForest_90' -> '1') }.
			         { ('coverForest_90' -> '1') }.
			         { ('coverCity_90' -> '1') }.
			         { ('coverOpenLand_90' -> '1') }.
			         { ('coverOpenLand_90' -> '1') } }.

	self assert: (model cellAt: 1 at: 1) boars closeTo: 0.6.
	self assert: (model cellAt: 1 at: 2) boars equals: 0.
	self assert: (model cellAt: 1 at: 3) boars equals: 0.
	self assert: (model cellAt: 1 at: 4) boars equals: 0.
	self assert: (model cellAt: 1 at: 5) boars closeTo: 20 * 0.8 * 0.01
]

{ #category : 'tests' }
BBBoarTest >> testFullPlotSendsATenthOfItsBoarsToEmptyNeighbours [
	"A full plot disperses at the maximum rate of 0.1, and its two empty neighbours are equally attractive"

	| model |
	model := self modelWithRowOfCovers: {
			         { ('coverForest_90' -> '1') }.
			         { ('coverForest_90' -> '1') }.
			         { ('coverForest_90' -> '1') } }.
	(model cellAt: 1 at: 1) boars: 0.
	(model cellAt: 1 at: 2) boars: 33.
	(model cellAt: 1 at: 3) boars: 0.
	model disperseBoarsByDensity.

	self assert: (model cellAt: 1 at: 1) boars closeTo: 1.65.
	self assert: (model cellAt: 1 at: 2) boars closeTo: 29.7.
	self assert: (model cellAt: 1 at: 3) boars closeTo: 1.65
]

{ #category : 'tests' }
BBBoarTest >> testOvercrowdedBoarsDieOutRatherThanGoBelowZero [

	| plot |
	plot := (self modelWithRowOfCovers: { { ('coverForest_90' -> '1') } })
		        cellAt: 1
		        at: 1.
	plot boars: 1000.
	plot grow.

	self assert: plot boars equals: 0
]
