"
I check how the land cover of a plot changes each year: towards the next observed map until 2018, then at the speed of 2012 to 2018, and how urban grass turns into trees after 2018.
"
Class {
	#name : 'BBLandCoverTest',
	#superclass : 'BBTestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'tests' }
BBLandCoverTest >> testAfter2018CoverKeepsChangingAtTheSpeedOf2012To2018 [

	| cover |
	cover := BBLandCover fromRow: (self coverRowAt: 1 @ 1 with: {
				          ('coverForest_12' -> '0,5').
				          ('coverForest_18' -> '0,44') }).
	2000 to: 2019 do: [ :year | cover changeIn: year ].

	self assert: (cover fractionOf: #Forest) closeTo: 0.43
]

{ #category : 'tests' }
BBLandCoverTest >> testCoverIsTheObservedMapInObservedYears [

	| cover |
	cover := BBLandCover fromRow: (self coverRowAt: 1 @ 1 with: {
				          ('coverForest_90' -> '0,6').
				          ('coverForest_00' -> '0,4').
				          ('coverCity_00' -> '0,1') }).
	1991 to: 2000 do: [ :year | cover changeIn: year ].

	self
		assert: (cover fractionOf: #Forest)
		equals: (cover fractionOf: #Forest in: 2000).
	self
		assert: (cover fractionOf: #City)
		equals: (cover fractionOf: #City in: 2000).
	self assert: (cover fractionOf: #Forest in: 1990) closeTo: 0.6
]

{ #category : 'tests' }
BBLandCoverTest >> testCoverMovesTowardsTheNextObservedMapEachYear [

	| cover |
	cover := BBLandCover fromRow: (self coverRowAt: 1 @ 1 with: {
				          ('coverForest_90' -> '0,6').
				          ('coverForest_00' -> '0,4') }).
	cover changeIn: 1991.

	self assert: (cover fractionOf: #Forest) closeTo: 0.58
]

{ #category : 'tests' }
BBLandCoverTest >> testGrowingCoversGiveWayWhenThePlotIsFull [
	"In 2019, city grows by 0.03, forest by 0.01 and farmland shrinks by 0.01: the 0.03 too much is taken from city and forest in proportion to their growth"

	| cover |
	cover := BBLandCover fromRow: (self coverRowAt: 1 @ 1 with: {
				          ('coverCity_12' -> '0,22').
				          ('coverForest_12' -> '0,24').
				          ('coverAgri_12' -> '0,36').
				          ('coverCity_18' -> '0,4').
				          ('coverForest_18' -> '0,3').
				          ('coverAgri_18' -> '0,3') }).
	2018 to: 2019 do: [ :year | cover changeIn: year ].

	self assert: (cover fractionOf: #City) closeTo: 0.43 - 0.0225.
	self assert: (cover fractionOf: #Forest) closeTo: 0.31 - 0.0075.
	self assert: (cover fractionOf: #Agri) closeTo: 0.29
]

{ #category : 'tests' }
BBLandCoverTest >> testShrubsTurnUrbanGrassIntoTrees [

	| cover |
	cover := BBLandCover fromRow: (self coverRowAt: 1 @ 1 with: {
				          ('treeCity' -> '0,2').
				          ('grassCity' -> '0,5') }).
	cover encroachShrubsBy: 0.1.

	self assert: cover urbanTrees closeTo: 0.3.
	self assert: cover urbanGrass closeTo: 0.4
]
