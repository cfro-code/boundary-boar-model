"
I check how land cover, anthropogenic food and acorns make the carrying capacity and the growth rate of boars on a plot.
"
Class {
	#name : 'BBHabitatTest',
	#superclass : 'BBTestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'helpers' }
BBHabitatTest >> plotWithCover: someCoverAssociations plot: somePlotAssociations [
	"A plot alone on its grid, with the 1990 cover and plot columns given"

	^ (self
		   modelWithPlotRows:
		   { (self plotRowAt: 1 @ 1 with: somePlotAssociations) }
		   coverRows:
		   { (self coverRowAt: 1 @ 1 with: someCoverAssociations) })
		  cellAt: 1
		  at: 1
]

{ #category : 'tests' }
BBHabitatTest >> testAcornsMakeTheForestRicher [

	| plot |
	plot := self plotWithCover: { ('coverForest_90' -> '1') } plot: #(  ).
	plot cormasModel acornAvailability: 1.

	self assert: plot carryingCapacity closeTo: 36.
	self assert: plot growthRate closeTo: 0.6
]

{ #category : 'tests' }
BBHabitatTest >> testCityHabitatGrowsWithVegetationAndFood [
	"Trees 0.2 and grass 0.15 give an urban vegetation score of 0.7 * 0.5 + 0.3 * (0.03 / 0.18) = 0.4. Waste is 1 and feeding 0.3 in a dense, very poor area"

	| plot |
	plot := self
		        plotWithCover: {
				        ('coverCity_90' -> '1').
				        ('treeCity' -> '0,2').
				        ('grassCity' -> '0,15') }
		        plot: {
				        ('humanPopDensity' -> 'urbanDense').
				        ('livingStandard' -> 'veryLow') }.

	self assert: plot landCover urbanVegetationScore closeTo: 0.4.
	self
		assert: plot carryingCapacity
		closeTo: 20 * 0.2 * 0.4 * 1.5 * 1.15.
	self assert: plot growthRate closeTo: 0.4 * 0.7 * 0.4 * 1.15 * 1.045
]

{ #category : 'tests' }
BBHabitatTest >> testCityWithoutTreesIsNoHabitat [

	| plot |
	plot := self
		        plotWithCover: { ('coverCity_90' -> '1') }
		        plot: { ('humanPopDensity' -> 'urbanDense') }.

	self assert: plot carryingCapacity equals: 0
]

{ #category : 'tests' }
BBHabitatTest >> testEachCoverAddsItsShare [
	"Half forest and half farmland: 20 * (0.5 * 1.5 * 1.1 + 0.5 * 0.4 * 1.1)"

	| plot |
	plot := self
		        plotWithCover: {
				        ('coverForest_90' -> '0,5').
				        ('coverAgri_90' -> '0,5') }
		        plot: #(  ).

	self assert: plot carryingCapacity closeTo: 20.9
]

{ #category : 'tests' }
BBHabitatTest >> testPureForestWithAnAverageAcornYear [
	"The ODD's check: K = 20 * 1.5 * 1.1 and r = 0.4 * 1 * 1.25, with acorns at 0.5 in 1990"

	| plot |
	plot := self plotWithCover: { ('coverForest_90' -> '1') } plot: #(  ).

	self assert: plot cormasModel acornAvailability equals: 0.5.
	self assert: plot carryingCapacity closeTo: 33.
	self assert: plot growthRate closeTo: 0.5
]

{ #category : 'tests' }
BBHabitatTest >> testSeaIsNoHabitat [

	| plot |
	plot := self plotWithCover: { ('coverSea_90' -> '1') } plot: #(  ).

	self assert: plot carryingCapacity equals: 0.
	self assert: plot growthRate equals: 0
]
