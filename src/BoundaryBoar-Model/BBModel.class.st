"
I am BOUNDARYBOAR, a model of wild boar populations at the rural-urban interface of Montpellier, ported from the Cormas VisualWorks model `BOUNDARYBOAR_V3`. One step is one year, starting from the landscape of 1990.

## Responsibility:

- Create the hexagonal landscape of Montpellier from the plot and cover tables of my data folder.
- Group plots into municipalities, administrative territories and hunting units.
- Know the acorn mast of the current year, the same on every plot.
- Create one road, highway or river per edge listed in the plot table.
- Run the yearly schedule of the model, from 1991 to 2028: the acorns of the year and the land cover change, boars grow, then move from crowded plots, all at once, associations measure the satisfaction of residents, farmers measure their damage, and from 2019 cities choose policies and farmers protect their crops, hunting groups organize their driven hunts, hunts, stands and cars kill boars, and hunted boars flee. In 2018, Montpellier bans hunting.

## Collaborators:

- `BBPlot`: the cells of my grid, in which odd columns are shifted down by half a cell, as in the original.
- `BBLandCover`: the land cover of each plot.
- `BBCity` and `BBHuntingGroup`: the managers of the territories, and `BBHuntingFederation`.
- `BBFarmer`: the farmers of each plot with farmland in 1990.
- `BBAssociation`: the neighbourhood associations of the dense towns of 2018, and `BBAdministrativeEntity`: the inter-municipal bodies.
- `BBRoad`, `BBHighway` and `BBRiver`: the links on the edges between plots, from one `BBNode` to another at the corners of the edges.
- `BBCityTerritory`, `BBAdministrativeTerritory` and `BBHuntingUnit`: the territories.

## Public API and Key Messages

- `initMontpellier` creates the landscape of 1990 from `plotMtpBis.csv` and `coverMtpBis.csv`.
- `year` answers the year of the current step, 1990 plus the time step. The acorn series stops in 2028, so a simulation runs at most 38 steps.
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

{ #category : 'towns' }
BBModel >> applyCityPolicies [
	"Cities whose residents complain choose a policy. Inter-municipal bodies may ban hunting or have their cities follow each other. Then waste and feeding follow the policies"

	(self allEntitiesOfClass: BBCity) do: [ :each | each decidePolicy ].
	(self allEntitiesOfClass: BBAdministrativeEntity) do: [ :each |
		each applyPolicies ].
	(self allEntitiesOfClass: BBCity) do: [ :each |
		each applyFoodPolicies ]
]

{ #category : 'hunting' }
BBModel >> applyScenariosIn: aYear [
	"In 2018, Montpellier bans hunting on its territory, as in the original model"

	aYear = 2018 ifTrue: [
			((self allEntitiesOfClass: BBCity) detect: [ :each |
				 each name = 'MONTPELLIER' ]) banHunting ]
]

{ #category : 'farming' }
BBModel >> assessDamage [

	(self allEntitiesOfClass: BBFarmer) do: [ :each | each assessDamage ]
]

{ #category : 'towns' }
BBModel >> assessSatisfaction [

	(self allEntitiesOfClass: BBAssociation) do: [ :each |
		each assessSatisfaction ]
]

{ #category : 'initialization' }
BBModel >> createAssociations [
	"One neighbourhood association on each plot that was more than 30 % city in 2018, even when the simulation starts in 1990. Residents of Montpellier Méditerranée Métropole like boars more than elsewhere"

	(self cells select: [ :each |
		 (each landCover fractionOf: #City in: 2018) > 0.3 ]) do: [ :plot |
			(self newEntity: BBAssociation locatedAt: plot) profile:
				(plot administrativeName = 'MMM'
					 ifTrue: [
							 {
								 (#coexistence -> 0.5).
								 (#ambivalent -> 0.2).
								 (#worried -> 0.3) } asDictionary ]
					 ifFalse: [
							 {
								 (#coexistence -> 0.1).
								 (#ambivalent -> 0.5).
								 (#worried -> 0.4) } asDictionary ]) ].
	self assessSatisfaction
]

{ #category : 'initialization' }
BBModel >> createFarmers [
	"Each plot with farmland in 1990 has one farmer, plus more the more farmland it has. Each crop with a large enough share of the farmland has at least one farmer, who share it equally"

	self cells do: [ :plot |
			| farmland farmers |
			farmland := plot landCover fractionOf: #Agri in: 1990.
			farmland > 0 ifTrue: [
					farmers := 1
					           +
					           (farmland * (BBFarmer maximumFarmersPerPlot - 1))
						           floor.
					{
						BBWineGrower.
						BBGrainFarmer.
						BBVegetableFarmer } do: [ :farmerClass |
							| share count |
							share := plot landCover agriculturalShareOf: farmerClass crop.
							share >= BBFarmer minimumCropShare ifTrue: [
									count := (share * farmers) rounded max: 1.
									count timesRepeat: [
											(self newEntity: farmerClass locatedAt: plot)
												surface: share * farmland / count;
												decideWhetherICanAffordPermanentFences ] ] ] ] ]
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
BBModel >> createManagers [
	"One municipality for each city territory, one inter-municipal body for each administrative territory, one local hunting group for each hunting unit, the hunting federation, the farmers of each plot and the neighbourhood associations"

	(self allEntitiesOfClass: BBCityTerritory) do: [ :each |
			each city: ((self newEntity: BBCity)
					 territory: each;
					 yourself) ].
	(self allEntitiesOfClass: BBAdministrativeTerritory) do: [ :each |
		(self newEntity: BBAdministrativeEntity) territory: each ].
	(self allEntitiesOfClass: BBHuntingUnit) do: [ :each |
			each huntingGroup: ((self newEntity: BBHuntingGroup)
					 huntingUnit: each;
					 yourself) ].
	self newEntity: BBHuntingFederation.
	self createFarmers.
	self createAssociations
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
BBModel >> disperseBoarsByHunting [

	self disperseBoars: [ :plot | plot huntingDispersers ]
]

{ #category : 'boars' }
BBModel >> growBoars [

	self cells do: [ :each | each grow ]
]

{ #category : 'hunting' }
BBModel >> huntBoars [
	"Driven hunts kill their share of the boars of their plot, from the numbers before the hunts. Then stands kill their share of what is left"

	self huntBoarsWith: BBDrivenHunt.
	(self allEntitiesOfClass: BBHuntingUnit) do: [ :each |
		each recordBag ].
	self huntBoarsWith: BBStand
]

{ #category : 'hunting' }
BBModel >> huntBoarsWith: aRegulationClass [

	(self allEntitiesOfClass: aRegulationClass) do: [ :each | each hunt ].
	self cells do: [ :each |
		each loseBoarsKilledBy: (each occupantsOfClass: aRegulationClass) ]
]

{ #category : 'farming' }
BBModel >> huntingFederation [

	^ (self allEntitiesOfClass: BBHuntingFederation) first
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
	"Create the grid, the plots, their land cover, the roads, highways and rivers between them, their boars and the people who manage them, from the rows of the plot and cover tables, which give one row per plot"

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
	self cells do: [ :each | each initializeBoars ].
	self createManagers
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

{ #category : 'hunting' }
BBModel >> organizeHuntsIn: aYear [

	(self allEntitiesOfClass: BBHuntingGroup) do: [ :each |
		each organizeHuntsIn: aYear ]
]

{ #category : 'private' }
BBModel >> plotInRow: aRow [
	"Answer the plot that a row of the plot or cover table describes"

	^ self
		  cellAt: (aRow at: 'rowIndex') asNumber
		  at: (aRow at: 'colIndex') asNumber
]

{ #category : 'farming' }
BBModel >> protectCrops [
	"Farmers ask the hunting federation for temporary fences, which it gives the most damaged first. Then those without temporary fences may install permanent ones, and those under heavy pressure hunt on their plot"

	| farmers |
	farmers := self allEntitiesOfClass: BBFarmer.
	farmers do: [ :each | each removeTemporaryFences ].
	self huntingFederation grantTemporaryFencesTo:
		(farmers select: [ :each | each needsTemporaryFences ]).
	farmers do: [ :each |
			each considerPermanentFences.
			each considerStand ]
]

{ #category : 'hunting' }
BBModel >> removeStands [
	"Stands last one year"

	(self allEntitiesOfClass: BBStand) do: [ :each | each delete ]
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
	"One year. People take action against boars from 2019"

	<control>
	self removeStands.
	self resetRoadCollisions.
	self updateAcorns.
	self applyScenariosIn: self year.
	self cells do: [ :each | each changeLandCoverIn: self year ].
	self growBoars.
	self disperseBoarsByDensity.
	self assessSatisfaction.
	self assessDamage.
	self year > 2018 ifTrue: [
			self applyCityPolicies.
			self protectCrops ].
	self organizeHuntsIn: self year.
	self huntBoars.
	self killBoarsOnRoads.
	self disperseBoarsByHunting
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

{ #category : 'acorns' }
BBModel >> updateAcorns [

	acornAvailability := self acornSeries at: self currentTimeStep + 1
]

{ #category : 'acorns' }
BBModel >> year [
	"The year of the current step: the simulation starts in 1990"

	^ 1990 + self currentTimeStep
]
