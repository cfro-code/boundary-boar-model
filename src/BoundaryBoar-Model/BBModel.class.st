"
I am BOUNDARYBOAR, a model of wild boar populations at the rural-urban interface of Montpellier, ported from the Cormas VisualWorks model `BOUNDARYBOAR_V3`. One step is one year, starting from the landscape of 1990.

## Responsibility:

- Create the hexagonal landscape of Montpellier from the plot and cover tables of my data folder.
- Group plots into municipalities, administrative territories and hunting units.
- Know the acorn mast of the current year, the same on every plot.
- Create one road, highway or river per edge listed in the plot table.
- Run the yearly schedule of the model, from 1991 to 2028: the acorns of the year and the land cover change, boars grow, then move from crowded plots, all at once, associations measure the satisfaction of residents, farmers measure their damage, and from 2019 cities choose policies, cities and farmers ask the State services to intervene, farmers protect their crops and the State services intervene, hunting groups organize their driven hunts, hunts, stands and cars kill boars, and hunted boars flee. In 2018, Montpellier bans hunting.

## Collaborators:

- `BBPlot`: the cells of my grid, in which odd columns are shifted down by half a cell, as in the original.
- `BBLandCover`: the land cover of each plot.
- `BBCity` and `BBHuntingGroup`: the managers of the territories, and `BBHuntingFederation` and `BBDDTM`, the hunting federation and the State services.
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

- My probes chart the outputs of the original model: boars, urban boars, bags, hunts, collisions, farmer damage and fences, the fence budget, city policies, the satisfaction of residents, habitat, and the boars of Montferrier and of the Mosson.
- My perspectives answer one question each: land cover, boars, habitat, hunting, farming, towns and territories. A simulation of Montpellier opens with the land cover.

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

{ #category : 'probes' }
BBModel >> bag [

	<probeNamed: 'Bag of driven hunts' color: 'FF7F0E'>
	^ (self allEntitiesOfClass: BBDrivenHunt)
		  inject: 0
		  into: [ :sum :each | sum + each boarsKilled ]
]

{ #category : 'probes' }
BBModel >> boars [

	<probeNamed: 'Boars' color: '8B4513'>
	^ self totalBoars
]

{ #category : 'private' }
BBModel >> boarsAt: somePositions [
	"Answer the boars of the plots at the positions row @ column"

	^ somePositions
		  inject: 0
		  into: [ :sum :each | sum + (self cellAt: each x at: each y) boars ]
]

{ #category : 'probes' }
BBModel >> collisions [

	<probeNamed: 'Road collisions' color: '5E5E5E'>
	^ self roadCollisions
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
	"One municipality for each city territory, one inter-municipal body for each administrative territory, one local hunting group for each hunting unit, the hunting federation, the State services, the farmers of each plot and the neighbourhood associations"

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
	self newEntity: BBDDTM.
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

{ #category : 'hunting' }
BBModel >> ddtm [
	"The State services of the department"

	^ (self allEntitiesOfClass: BBDDTM) first
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

{ #category : 'probes' }
BBModel >> drivenHunts [

	<probeNamed: 'Driven hunts' color: 'FFBB78'>
	^ (self allEntitiesOfClass: BBDrivenHunt) size
]

{ #category : 'probes' }
BBModel >> farmersStands [

	<probeNamed: 'Stands of farmers' color: '17BECF'>
	^ (self allEntitiesOfClass: BBStand) count: [ :each |
		  each organizer isKindOf: BBFarmer ]
]

{ #category : 'probes' }
BBModel >> farmersWithPermanentFences [

	<probeNamed: 'Farmers with permanent fences' color: '1F77B4'>
	^ (self allEntitiesOfClass: BBFarmer) count: [ :each |
		  each hasPermanentFences ]
]

{ #category : 'probes' }
BBModel >> farmersWithTemporaryFences [

	<probeNamed: 'Farmers with temporary fences' color: 'AEC7E8'>
	^ (self allEntitiesOfClass: BBFarmer) count: [ :each |
		  each hasTemporaryFences ]
]

{ #category : 'probes' }
BBModel >> federationBudget [

	<probeNamed: 'Fence budget of the hunting federation' color: '9467BD'>
	^ self huntingFederation fenceBudget
]

{ #category : 'boars' }
BBModel >> growBoars [

	self cells do: [ :each | each grow ]
]

{ #category : 'hunting' }
BBModel >> huntBoars [
	"Driven hunts kill their share of the boars of their plot, from the numbers before the hunts. Then stands, then traps, kill their share of what is left"

	self huntBoarsWith: BBDrivenHunt.
	(self allEntitiesOfClass: BBHuntingUnit) do: [ :each |
		each recordBag ].
	self huntBoarsWith: BBStand.
	self huntBoarsWith: BBTrapping
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
	<perspective: #perspectiveLandCover>
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

{ #category : 'private' }
BBModel >> mean: aBlock over: aCollection [
	"Answer the mean of aBlock over aCollection, or 0 when it is empty, so that charts keep a value"

	aCollection isEmpty ifTrue: [ ^ 0 ].
	^ (aCollection
		   inject: 0
		   into: [ :sum :each | sum + (aBlock value: each) ])
	  / aCollection size
]

{ #category : 'probes' }
BBModel >> meanBrushcuttingCampaigns [

	<probeNamed: 'Mean brush-cutting campaigns' color: '2CA02C'>
	^ self
		  mean: [ :each | each brushcuttingCampaigns ]
		  over: (self allEntitiesOfClass: BBCity)
]

{ #category : 'probes' }
BBModel >> meanFarmerDamage [

	<probeNamed: 'Mean farmer damage' color: 'F1D54B'>
	^ self
		  mean: [ :each | each damage ]
		  over: (self allEntitiesOfClass: BBFarmer)
]

{ #category : 'probes' }
BBModel >> meanFeedingPolicy [

	<probeNamed: 'Mean feeding policy' color: 'D62728'>
	^ self
		  mean: [ :each | each feedingPolicy ]
		  over: (self allEntitiesOfClass: BBCity)
]

{ #category : 'probes' }
BBModel >> meanGrowthRate [
	"The mean growth rate of the plots where boars can grow"

	<probeNamed: 'Mean growth rate' color: '7F7F7F'>
	^ self
		  mean: [ :each | each ]
		  over:
			  ((self cells collect: [ :each | each growthRate ]) select: [
				   :each | each > 0 ])
]

{ #category : 'probes' }
BBModel >> meanSatisfaction [

	<probeNamed: 'Mean satisfaction of residents' color: '98DF8A'>
	^ self
		  mean: [ :each | each satisfaction ]
		  over: (self allEntitiesOfClass: BBAssociation)
]

{ #category : 'probes' }
BBModel >> meanWastePolicy [

	<probeNamed: 'Mean waste policy' color: 'FF7F0E'>
	^ self
		  mean: [ :each | each wastePolicy ]
		  over: (self allEntitiesOfClass: BBCity)
]

{ #category : 'probes' }
BBModel >> montferrierBoars [
	"The boars of the three plots of Montferrier-sur-Lez, as in the original model"

	<probeNamed: 'Boars in Montferrier' color: 'BCBD22'>
	^ self boarsAt: {
			  (6 @ 11).
			  (6 @ 12).
			  (7 @ 12) }
]

{ #category : 'probes' }
BBModel >> mossonBoars [
	"The boars of the three plots of the Mosson district of Montpellier, as in the original model"

	<probeNamed: 'Boars in the Mosson' color: 'DBDB8D'>
	^ self boarsAt: {
			  (9 @ 11).
			  (10 @ 10).
			  (10 @ 11) }
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

{ #category : 'perspectives' }
BBModel >> perspectiveBoars [
	"Where are the boars? Their number on each plot, with the hunts, stands and traps that kill them"

	<perspective>
	^ CMPerspective new
		  show: BBPlot as: #aspectBoars:;
		  hide: BBFarmer;
		  hide: BBAssociation;
		  yourself
]

{ #category : 'perspectives' }
BBModel >> perspectiveFarming [
	"How do farmers protect their crops? Farmland, the fences of each farmer, and their stands"

	<perspective>
	^ CMPerspective new
		  show: BBPlot as: #aspectFarmland:;
		  show: BBFarmer as: #aspectFences:;
		  hide: BBDrivenHunt;
		  hide: BBTrapping;
		  hide: BBAssociation;
		  yourself
]

{ #category : 'perspectives' }
BBModel >> perspectiveHabitat [
	"Where can boars live? The carrying capacity of each plot"

	<perspective>
	^ CMPerspective new
		  show: BBPlot as: #aspectCarryingCapacity:;
		  hide: BBFarmer;
		  hide: BBAssociation;
		  hide: BBRegulation;
		  yourself
]

{ #category : 'perspectives' }
BBModel >> perspectiveHunting [
	"Who hunts where? Hunting units, with each hunt, stand or trap in the color of its organizer"

	<perspective>
	^ CMPerspective new
		  show: BBPlot as: #aspectHuntingUnit:;
		  show: BBRegulation as: #aspectOrganizer:;
		  hide: BBFarmer;
		  hide: BBAssociation;
		  yourself
]

{ #category : 'perspectives' }
BBModel >> perspectiveLandCover [
	"What is the landscape? The main land cover of each plot, with roads, highways and rivers"

	<perspective>
	^ CMPerspective new
		  show: BBPlot as: #aspectDefault:;
		  hide: BBFarmer;
		  hide: BBAssociation;
		  hide: BBRegulation;
		  yourself
]

{ #category : 'perspectives' }
BBModel >> perspectiveTerritories [
	"Who manages what? Municipalities, with the borders of all territories"

	<perspective>
	^ CMPerspective new
		  show: BBPlot as: #aspectMunicipality:;
		  show: BBTerritory as: #aspectBorder:;
		  hide: BBFarmer;
		  hide: BBAssociation;
		  hide: BBRegulation;
		  yourself
]

{ #category : 'perspectives' }
BBModel >> perspectiveTowns [
	"Are residents satisfied, and what do their cities do? Waste policies, and the satisfaction of each association"

	<perspective>
	^ CMPerspective new
		  show: BBPlot as: #aspectWastePolicy:;
		  hide: BBFarmer;
		  hide: BBRegulation;
		  yourself
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
	"Farmers ask the hunting federation for temporary fences, which it gives the most damaged first. Then those without temporary fences may install permanent ones, those under heavy pressure hunt on their plot, and those who cannot ask the State services"

	| farmers |
	farmers := self allEntitiesOfClass: BBFarmer.
	farmers do: [ :each | each removeTemporaryFences ].
	self huntingFederation grantTemporaryFencesTo:
		(farmers select: [ :each | each needsTemporaryFences ]).
	farmers do: [ :each |
			each considerPermanentFences.
			each considerStand.
			each considerAskingTheDDTM ]
]

{ #category : 'hunting' }
BBModel >> removeOneYearRegulations [
	"Stands, traps and the hunts of the State services last one year. Hunting groups keep their hunts"

	((self allEntitiesOfClass: BBRegulation) select: [ :each |
		 each lastsOneYear ]) do: [ :each | each delete ]
]

{ #category : 'hunting' }
BBModel >> requestInterventions [

	(self allEntitiesOfClass: BBCity) do: [ :each |
		each requestInterventions ]
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
	self removeOneYearRegulations.
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
			self requestInterventions.
			self protectCrops.
			self ddtm intervene ].
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

{ #category : 'probes' }
BBModel >> totalCarryingCapacity [

	<probeNamed: 'Total carrying capacity' color: '2C7A2C'>
	^ self cells
		  inject: 0
		  into: [ :sum :each | sum + each carryingCapacity ]
]

{ #category : 'acorns' }
BBModel >> updateAcorns [

	acornAvailability := self acornSeries at: self currentTimeStep + 1
]

{ #category : 'probes' }
BBModel >> urbanBoars [
	"As in the original model, this probe divides by the habitat potential of each plot, where associations divide by its habitat quality"

	<probeNamed: 'Urban boars' color: 'D62728'>
	^ self cells inject: 0 into: [ :sum :each |
			  | potential |
			  potential := each habitatPotential.
			  potential > 0
				  ifTrue: [
				  sum + (each boars * (each habitatQualityOf: #City) / potential) ]
				  ifFalse: [ sum ] ]
]

{ #category : 'probes' }
BBModel >> urbanBoarsPerTown [
	"Urban boars for each plot's worth of city"

	<probeNamed: 'Urban boars per plot of city' color: 'FF9896'>
	| city |
	city := self cells
		        inject: 0
		        into: [ :sum :each |
		        sum + (each landCover fractionOf: #City) ].
	city = 0 ifTrue: [ ^ 0 ].
	^ self urbanBoars / city
]

{ #category : 'acorns' }
BBModel >> year [
	"The year of the current step: the simulation starts in 1990"

	^ 1990 + self currentTimeStep
]
