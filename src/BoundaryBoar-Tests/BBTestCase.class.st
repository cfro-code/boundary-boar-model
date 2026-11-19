"
I am the superclass of the BoundaryBoar tests. I build small landscapes from rows of the plot and cover tables, with defaults for the columns a test does not care about.
"
Class {
	#name : 'BBTestCase',
	#superclass : 'TestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'testing' }
BBTestCase class >> isAbstract [

	^ self == BBTestCase
]

{ #category : 'helpers' }
BBTestCase >> coverRowAt: aPoint with: someAssociations [
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
BBTestCase >> modelWithPlotRows: somePlotRows [
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
BBTestCase >> modelWithPlotRows: somePlotRows coverRows: someCoverRows [

	^ BBModel new
		  initWithPlotTable: somePlotRows coverTable: someCoverRows;
		  yourself
]

{ #category : 'helpers' }
BBTestCase >> plotRowAt: aPoint with: someAssociations [
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
	#( 'N' 'NE' 'SE' 'S' 'SW' 'NW' ) do: [ :direction |
		row at: 'edge' , direction put: '' ].
	someAssociations do: [ :each | row add: each ].
	^ row
]
