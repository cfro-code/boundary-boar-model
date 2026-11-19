"
I check the rules that create the landscape: anthropogenic food on plots, land cover, and the territories plots belong to.
"
Class {
	#name : 'BBModelTest',
	#superclass : 'TestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'helpers' }
BBModelTest >> coverRowAt: aPoint with: someAssociations [
	"A row of the cover table for the plot at row aPoint x and column aPoint y, with no cover and empty vegetation and crop columns unless given"

	| row |
	row := Dictionary new.
	row at: 'rowIndex' put: aPoint x printString.
	row at: 'colIndex' put: aPoint y printString.
	#( 'City' 'IndusZone' 'OpenLand' 'Forest' 'Agri' 'Wetland' 'Sea'
	   'BurntArea' ) do: [ :type |
			#( '90' '00' '06' '12' '18' ) do: [ :suffix |
				row at: 'cover' , type , '_' , suffix put: '0' ] ].
	#( 'treeCity' 'grassCity' 'wine' 'grain' 'vegetable' ) do: [ :column |
		row at: column put: '' ].
	someAssociations do: [ :each | row add: each ].
	^ row
]

{ #category : 'helpers' }
BBModelTest >> modelWithPlotRows: somePlotRows [
	"A model where no plot has any land cover"

	^ self
		  modelWithPlotRows: somePlotRows
		  coverRows: (somePlotRows collect: [ :each |
					   self
						   coverRowAt:
						   (each at: 'rowIndex') asNumber
						   @ (each at: 'colIndex') asNumber
						   with: #(  ) ])
]

{ #category : 'helpers' }
BBModelTest >> modelWithPlotRows: somePlotRows coverRows: someCoverRows [

	^ BBModel new
		  initWithPlotTable: somePlotRows coverTable: someCoverRows;
		  yourself
]

{ #category : 'helpers' }
BBModelTest >> plotRowAt: aPoint with: someAssociations [
	"A row of the plot table for the plot at row aPoint x and column aPoint y, with defaults for the columns not given"

	| row |
	row := Dictionary newFrom: {
			       ('rowIndex' -> aPoint x printString).
			       ('colIndex' -> aPoint y printString).
			       ('huntingUnit' -> '8').
			       ('cityTerritory' -> 'GRABELS').
			       ('administrativeTerritory' -> 'MMM').
			       ('humanPopDensity' -> 'noPop').
			       ('livingStandard' -> 'NA') }.
	someAssociations do: [ :each | row add: each ].
	^ row
]

{ #category : 'tests' }
BBModelTest >> testLandCoverStartsFromThe1990Map [

	| model cover |
	model := self
		         modelWithPlotRows: { (self plotRowAt: 1 @ 1 with: #(  )) }
		         coverRows: { (self coverRowAt: 1 @ 1 with: {
					          ('coverForest_90' -> '0,6').
					          ('coverOpenLand_90' -> '0,3').
					          ('coverCity_90' -> '').
					          ('coverCity_18' -> '0,5').
					          ('coverForest_18' -> '0,4') }) }.
	cover := (model cellAt: 1 at: 1) landCover.

	self assert: (cover fractionOf: #Forest) closeTo: 0.6.
	self assert: (cover fractionOf: #OpenLand) closeTo: 0.3.
	self assert: (cover fractionOf: #City) equals: 0.
	self assert: cover mainCover equals: #Forest.
	self assert: (cover fractionOf: #City in: 2018) closeTo: 0.5
]

{ #category : 'tests' }
BBModelTest >> testMunicipalityGathersAllItsPlotsEvenWhenTheyAreApart [

	| model territory |
	model := self modelWithPlotRows: {
			         (self
				          plotRowAt: 1 @ 1
				          with: { ('cityTerritory' -> 'GRABELS') }).
			         (self
				          plotRowAt: 1 @ 2
				          with: { ('cityTerritory' -> 'JUVIGNAC') }).
			         (self
				          plotRowAt: 1 @ 3
				          with: { ('cityTerritory' -> 'GRABELS') }) }.
	territory := (model cellAt: 1 at: 1) cityTerritory.

	self assert: territory name equals: 'GRABELS'.
	self
		assert: (model cellAt: 1 at: 3) cityTerritory
		identicalTo: territory.
	self
		deny: (model cellAt: 1 at: 2) cityTerritory
		identicalTo: territory
]

{ #category : 'tests' }
BBModelTest >> testResidentsFeedBoarsMoreInDenseAreas [
	"As in the original model, feeding does not depend on the residents' attitudes at the start"

	| model |
	model := self modelWithPlotRows: {
			         (self
				          plotRowAt: 1 @ 1
				          with: { ('humanPopDensity' -> 'urbanDense') }).
			         (self
				          plotRowAt: 1 @ 2
				          with: { ('humanPopDensity' -> 'urbanSemiDense') }).
			         (self
				          plotRowAt: 1 @ 3
				          with: { ('humanPopDensity' -> 'ruralLowToVeryLow') }) }.

	self assert: (model cellAt: 1 at: 1) feedingIntensity closeTo: 0.3.
	self assert: (model cellAt: 1 at: 2) feedingIntensity closeTo: 0.18.
	self assert: (model cellAt: 1 at: 3) feedingIntensity closeTo: 0.09
]

{ #category : 'tests' }
BBModelTest >> testTerritoriesAndHuntingUnitsGroupPlotsByName [

	| model |
	model := self modelWithPlotRows: {
			         (self plotRowAt: 1 @ 1 with: {
					          ('administrativeTerritory' -> 'MMM').
					          ('huntingUnit' -> '8') }).
			         (self plotRowAt: 1 @ 2 with: {
					          ('administrativeTerritory' -> 'MMM').
					          ('huntingUnit' -> 'NA') }).
			         (self plotRowAt: 1 @ 3 with: {
					          ('administrativeTerritory' -> 'CALunel').
					          ('huntingUnit' -> 'NA') }) }.

	self
		assert: (model cellAt: 1 at: 1) administrativeTerritory
		identicalTo: (model cellAt: 1 at: 2) administrativeTerritory.
	self
		assert: (model cellAt: 1 at: 3) administrativeTerritory name
		equals: 'CALunel'.
	self
		assert: (model cellAt: 1 at: 2) huntingUnit
		identicalTo: (model cellAt: 1 at: 3) huntingUnit.
	self assert: (model cellAt: 1 at: 1) huntingUnit name equals: '8'
]

{ #category : 'tests' }
BBModelTest >> testUrbanVegetationAndCropsComeFromTheCoverTable [

	| model cover |
	model := self
		         modelWithPlotRows: { (self plotRowAt: 1 @ 1 with: #(  )) }
		         coverRows: { (self coverRowAt: 1 @ 1 with: {
					          ('treeCity' -> '0,25').
					          ('grassCity' -> '0,1').
					          ('wine' -> '0,7').
					          ('grain' -> '0,3') }) }.
	cover := (model cellAt: 1 at: 1) landCover.

	self assert: cover urbanTrees closeTo: 0.25.
	self assert: cover urbanGrass closeTo: 0.1.
	self assert: (cover agriculturalShareOf: #wine) closeTo: 0.7.
	self assert: (cover agriculturalShareOf: #grain) closeTo: 0.3.
	self assert: (cover agriculturalShareOf: #vegetables) equals: 0
]

{ #category : 'tests' }
BBModelTest >> testWasteIsMoreAccessibleInDenseAndPoorAreas [

	| model |
	model := self modelWithPlotRows: {
			         (self plotRowAt: 1 @ 1 with: {
					          ('humanPopDensity' -> 'urbanDense').
					          ('livingStandard' -> 'veryLow') }).
			         (self plotRowAt: 1 @ 2 with: {
					          ('humanPopDensity' -> 'urbanSemiDense').
					          ('livingStandard' -> 'high') }).
			         (self plotRowAt: 1 @ 3 with: #(  )) }.

	self assert: (model cellAt: 1 at: 1) wasteAccessibility closeTo: 1.
	self assert: (model cellAt: 1 at: 2) wasteAccessibility closeTo: 0.64.
	self assert: (model cellAt: 1 at: 3) wasteAccessibility equals: 0
]
