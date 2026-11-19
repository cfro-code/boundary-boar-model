"
I am BOUNDARYBOAR, a model of wild boar populations at the rural-urban interface of Montpellier, ported from the Cormas VisualWorks model `BOUNDARYBOAR_V3`. One step is one year, starting from the landscape of 1990.

## Responsibility:

- Create the hexagonal landscape of Montpellier from the plot and cover tables of my data folder.
- Group plots into municipalities, administrative territories and hunting units.
- Know the acorn mast of the current year, the same on every plot.
- Create one road, highway or river per edge listed in the plot table.
- Run the yearly schedule of the model: boars grow, then move from crowded plots, all at once, and cars kill some of those living beside roads.

## Collaborators:

- `BBPlot`: the cells of my grid, in which odd columns are shifted down by half a cell, as in the original.
- `BBLandCover`: the land cover of each plot.
- `BBRoad`, `BBHighway` and `BBRiver`: the links on the edges between plots, from one `BBNode` to another at the corners of the edges.
- `BBCityTerritory`, `BBAdministrativeTerritory` and `BBHuntingUnit`: the territories.

## Public API and Key Messages

- `initMontpellier` creates the landscape of 1990 from `plotMtpBis.csv` and `coverMtpBis.csv`.
- `initWithPlotTable:coverTable:` creates a landscape from tables given as one dictionary per row, from column names to texts.

```
model := BBModel new.
model initMontpellier.
(model cellAt: 9 at: 12) cityTerritory name. ""'MONTPELLIER'""
```

### Implementation Points

The rules follow the ODD description of the original model, written from its code. Where this port differs from the original on purpose, the class concerned says so in its comment.
"
Class {
	#name : 'BBModel',
	#superclass : 'CMModel',
	#instVars : [
		'acornAvailability'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBModel class >> prefix [
	"Every class name in the model package begins with this prefix"

	^ 'BB'
]

{ #category : 'acorns' }
BBModel >> acornAvailability [
	"The acorn mast of the current year, the same on every plot"

	^ acornAvailability
]

{ #category : 'acorns' }
BBModel >> acornAvailability: aNumber [

	acornAvailability := aNumber
]

{ #category : 'acorns' }
BBModel >> acornSeries [
	"The acorn mast of each year from 1990 to 2028, between 0 and 1, as in the original model"

	^ #( 0.5 0.6 0.4 0.5 0.6 0.5 0.7 0.5 0.4 0.5 0.6 0.4 0.8 0.5 0.3 0.7
	     0.9 0.4 0.5 0.8 0.3 0.9 0.4 0.6 1.0 0.2 0.8 0.3 0.5 0.9 0.2 0.8
	     0.3 1.0 0.2 0.9 0.4 0.2 1.0 )
]

{ #category : 'initialization' }
BBModel >> addFeature: aFeatureClass towards: aDirection of: aPlot nodes: someNodes [
	"Create a feature on the edge of aPlot in aDirection, unless one of that class is there already"

	| neighbour corners feature |
	neighbour := aPlot neighbourTowards: aDirection.
	((aPlot featuresTowards: neighbour) anySatisfy: [ :each |
		 each class == aFeatureClass ]) ifTrue: [ ^ self ].
	corners := BBPlot edgeCorners at: aDirection.
	feature := self
		           newEntity: aFeatureClass
		           from:
		           (self nodeAt: corners first of: aPlot in: someNodes)
		           to: (self nodeAt: corners last of: aPlot in: someNodes).
	feature between: aPlot and: neighbour.
	aPlot addFeature: feature.
	neighbour addFeature: feature
]

{ #category : 'initialization' }
BBModel >> createLinearFeaturesFrom: somePlotRows [
	"The plot table lists each road, highway or river on both plots of its edge, such as 'RW' for a road and a river. Create one link of each type per edge, from the plot with the lower id, between nodes at the two corners of the edge"

	| nodes |
	nodes := Dictionary new.
	(somePlotRows asSortedCollection: [ :a :b |
		 (self plotInRow: a) id <= (self plotInRow: b) id ]) do: [ :row |
			| plot |
			plot := self plotInRow: row.
			#( #N #NE #SE #S #SW #NW ) do: [ :direction |
					(plot hasNeighbourTowards: direction) ifTrue: [
							(row at: 'edge' , direction) do: [ :letter |
									self
										addFeature: (BBLinearFeature forLetter: letter)
										towards: direction
										of: plot
										nodes: nodes ] ] ] ]
]

{ #category : 'initialization' }
BBModel >> createTerritories [

	self createTerritories: BBCityTerritory groupingPlotsBy: #cityName.
	self
		createTerritories: BBAdministrativeTerritory
		groupingPlotsBy: #administrativeName.
	self
		createTerritories: BBHuntingUnit
		groupingPlotsBy: #huntingUnitName
]

{ #category : 'initialization' }
BBModel >> createTerritories: aTerritoryClass groupingPlotsBy: aSelector [
	"Create one territory for each name, with all the plots of that name, whether they touch or not"

	(self cells groupedBy: aSelector) keysAndValuesDo: [ :name :plots |
		(self createAggregate: aTerritoryClass from: plots) name: name ]
]

{ #category : 'boars' }
BBModel >> disperseBoars: aBlock [
	"Move the boars that aBlock answers for each plot, all at once: every plot decides how many leave from the numbers before anyone moves"

	self cells do: [ :each | each resetDispersal ].
	self cells do: [ :each | each sendDispersers: (aBlock value: each) ].
	self cells do: [ :each | each settleDispersers ]
]

{ #category : 'boars' }
BBModel >> disperseBoarsByDensity [

	self disperseBoars: [ :plot | plot densityDispersers ]
]

{ #category : 'boars' }
BBModel >> growBoars [

	self cells do: [ :each | each grow ]
]

{ #category : 'initialization' }
BBModel >> initMontpellier [
	"The landscape of Montpellier in 1990"

	<init>
	self
		initWithPlotTable: (self tableNamed: 'plotMtpBis.csv')
		coverTable: (self tableNamed: 'coverMtpBis.csv')
]

{ #category : 'initialization' }
BBModel >> initWithPlotTable: somePlotRows coverTable: someCoverRows [
	"Create the grid, the plots, their land cover, the roads, highways and rivers between them and their boars from the rows of the plot and cover tables, which give one row per plot"

	acornAvailability := self acornSeries first.
	self
		createGridNumberOfRows:
		(somePlotRows collect: [ :row | (row at: 'rowIndex') asNumber ]) max
		numberOfColumns:
		(somePlotRows collect: [ :row | (row at: 'colIndex') asNumber ]) max
		neighbourhood: #flat6OddColumnsDown
		closed: true.
	somePlotRows do: [ :row |
		(self plotInRow: row) initializeFromRow: row ].
	someCoverRows do: [ :row |
		(self plotInRow: row) landCover: (BBLandCover fromRow: row) ].
	self createTerritories.
	self createLinearFeaturesFrom: somePlotRows.
	self cells do: [ :each | each initializeBoars ]
]

{ #category : 'boars' }
BBModel >> killBoarsOnRoads [

	self cells do: [ :each | each killBoarsBesideRoads ]
]

{ #category : 'initialization' }
BBModel >> nodeAt: aCorner of: aPlot in: someNodes [
	"Answer the node at a corner of aPlot, creating it on aPlot if no plot around that corner has it yet. someNodes holds the nodes by their position on the grid"

	| position |
	position := BBPlot cornerPositions at: aCorner.
	^ someNodes
		  at: ((self spaceModel neighbourhoodConfiguration
				    gridPositionOf: aPlot
				    at: position) roundTo: 0.01)
		  ifAbsentPut: [
				  (self newEntity: BBNode locatedAt: aPlot)
					  positionInCell: position;
					  yourself ]
]

{ #category : 'private' }
BBModel >> plotInRow: aRow [
	"Answer the plot that a row of the plot or cover table describes"

	^ self
		  cellAt: (aRow at: 'rowIndex') asNumber
		  at: (aRow at: 'colIndex') asNumber
]

{ #category : 'boars' }
BBModel >> resetRoadCollisions [

	(self allEntitiesOfClass: BBRoad) do: [ :each | each resetCollisions ]
]

{ #category : 'boars' }
BBModel >> roadCollisions [
	"The number of boars killed by cars this year"

	^ (self allEntitiesOfClass: BBRoad)
		  inject: 0
		  into: [ :sum :each | sum + each collisions ]
]

{ #category : 'control' }
BBModel >> step [
	"One year"

	<control>
	self resetRoadCollisions.
	self growBoars.
	self disperseBoarsByDensity.
	self killBoarsOnRoads
]

{ #category : 'private' }
BBModel >> tableNamed: aFileName [
	"Read a table of the data folder, whose columns are separated by semicolons, as one dictionary per row from the column names to the texts of the row"

	| lines columnNames |
	lines := (self folder / 'data' / aFileName) contents lines.
	columnNames := lines first splitOn: $;.
	^ lines allButFirst collect: [ :line |
			  (columnNames
				   with: (line splitOn: $;)
				   collect: [ :name :text | name -> text ]) asDictionary ]
]

{ #category : 'boars' }
BBModel >> totalBoars [

	^ self cells sum: [ :each | each boars ]
]
