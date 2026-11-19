"
I am a hexagonal plot of the landscape around Montpellier. I know my land cover, the municipality, administrative territory and hunting unit I belong to, and how much anthropogenic food boars find on me.

## Responsibility:

- Read my attributes from a row of the plot table: the names of my territories, my human population density and my living standard.
- Know how accessible household waste is and how much residents feed boars, now and at the start.
- Know the number of boars I can hold and their growth rate, from my land cover, my anthropogenic food and the acorns of the year.
- Hold my boars: where they live in 1990, how they grow, and how many leave for my neighbours when I am crowded.
- Hold my `BBLandCover`, change it every year, and answer the territories I belong to.

## Collaborators:

- `BBModel` creates me from the plot table and gives me my land cover.
- `BBLandCover` holds the fractions of my area under each type of land cover.
- `BBCityTerritory`, `BBAdministrativeTerritory` and `BBHuntingUnit` are the territories I belong to.
- `BBRoad`, `BBHighway` and `BBRiver` lie on my edges: my dispersing boars cross them, and roads kill some of my boars.

## Public API and Key Messages

- `wasteAccessibility` and `feedingIntensity` answer the anthropogenic food on me, between 0 and 1.
- `carryingCapacity` and `growthRate` answer K and r, from `habitatQuality` and `habitatPotential`.
- `boars` answers the number of boars on me, `saturation` how full I am, and `grow` makes them grow for a year.
- `densityDispersers`, `sendDispersers:` and `settleDispersers` move boars to my neighbours, as `BBModel` orders.
- `isHuntable` answers whether hunters may hunt on me: I have a habitat, less than half of me is built up, and my city allows hunting. `regulations` answers the hunts and stands on me.
- `associations` answers my neighbourhood associations, `urbanSaturation` how full of boars my town is, and `projectedUrbanBoars` how many it will have next year; `limitWasteBy:` and `limitFeedingBy:` apply city policies.
- `farmers` answers my farmers, `farmlandBoars` how many of my boars live in my farmland, and `maximumFarmlandBoars` how many could.
- `landCover` answers my land cover.
- `cityTerritory`, `administrativeTerritory` and `huntingUnit` answer my territories.
- The weights of density and living standard, and the reference carrying capacity and growth rate, are parameters of my class. The values of each type of land cover are constants of my class.
- My aspects show my main land cover by default, and K, r, food, urban vegetation and territories.

```
plot := model cellAt: 5 at: 12.
plot wasteAccessibility. ""0.64 for a semi-dense area with a high living standard""
plot landCover mainCover. ""#City""
plot carryingCapacity. ""33 on a pure forest plot with acorns at 0.5""
```

## Internal Representation

- `humanPopDensity` is `#urbanDense`, `#urbanSemiDense`, `#ruralLowToVeryLow` or `#noPop`.
- `livingStandard` is `#veryLow`, `#low`, `#medium`, `#high`, `#veryHigh` or `#NA`.
- `initialWasteAccessibility` and `initialFeedingIntensity` are the values before any city policy; `wasteAccessibility` and `feedingIntensity` are the current ones.
- `cityName`, `administrativeName` and `huntingUnitName` are the names my territories are created from.
- `features` holds the roads, highways and rivers on my edges.
- `boars` is a number that need not be whole. `arrivingBoars` and `leavingBoars` add up the boars that move during one dispersal.

### Implementation Points

As in the original model, the initial feeding intensity depends only on the population density: the share of residents who like boars is not known yet when it is computed, because associations do not exist yet. The original also had a grain feeding intensity, always 0, which is left out.

Each type of land cover adds its fraction times its reference value, times one plus the weight of each of its food sources. Urban types are also scaled by the vegetation inside urban fabric. As in the original model, fences do not change K and r: the original gave them weights under names that its formula never looked up.

Boars are a number on each plot, where the original had one population agent per plot. Dispersing boars stopped by a road or a highway leave through the edges that stopped nobody. When every edge stopped some, they are lost, as in the original model.

Unlike the original, boars never go below zero after growth: an overcrowded plot loses all its boars instead.
"
Class {
	#name : 'BBPlot',
	#superclass : 'CMCell',
	#instVars : [
		'cityName',
		'administrativeName',
		'huntingUnitName',
		'humanPopDensity',
		'livingStandard',
		'initialWasteAccessibility',
		'wasteAccessibility',
		'initialFeedingIntensity',
		'feedingIntensity',
		'landCover',
		'boars',
		'arrivingBoars',
		'leavingBoars',
		'features'
	],
	#classInstVars : [
		'wasteDensityWeight',
		'wasteLivingStandardWeight',
		'feedingDensityWeight',
		'referenceCarryingCapacity',
		'referenceGrowthRate',
		'densityDependence',
		'maximumDispersalRate',
		'dispersalSteepness',
		'shrubEncroachmentRate',
		'acornDamageReduction',
		'acornUrbanReduction'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBPlot class >> acornDamageReduction [
	"How much less boars use farmland in a year of full acorn mast"

	<parameterFloatMin: 0 max: 1 default: 0.7>
	^ acornDamageReduction
]

{ #category : 'parameters' }
BBPlot class >> acornDamageReduction: aNumber [

	acornDamageReduction := aNumber
]

{ #category : 'parameters' }
BBPlot class >> acornUrbanReduction [
	"How much less boars come into towns in a year of full acorn mast"

	<parameterFloatMin: 0 max: 1 default: 0.7>
	^ acornUrbanReduction
]

{ #category : 'parameters' }
BBPlot class >> acornUrbanReduction: aNumber [

	acornUrbanReduction := aNumber
]

{ #category : 'habitat' }
BBPlot class >> carryingCapacityReferences [
	"The habitat quality of each type of land cover, before modifiers"

	^ {
		  (#Forest -> 1.5).
		  (#OpenLand -> 0.8).
		  (#Agri -> 0.4).
		  (#Wetland -> 0.5).
		  (#BurntArea -> 0).
		  (#Sea -> 0).
		  (#City -> 0.2).
		  (#IndusZone -> 0.1) } asDictionary
]

{ #category : 'habitat' }
BBPlot class >> carryingCapacityWeights [
	"How much each modifier raises habitat quality when it is 1"

	^ {
		  (#acornAvailability -> 0.2).
		  (#wasteAccessibility -> 0.5).
		  (#feedingIntensity -> 0.5) } asDictionary
]

{ #category : 'linear features' }
BBPlot class >> cornerPositions [
	"The corners of a flat-top hexagon, numbered as in the original model, as positions in the box around the plot, from 0@0 at its top left to 1@1 at its bottom right"

	^ {
		  (1 -> (0.25 @ 1)).
		  (2 -> (0 @ 0.5)).
		  (3 -> (0.25 @ 0)).
		  (4 -> (0.75 @ 0)).
		  (5 -> (1 @ 0.5)).
		  (6 -> (0.75 @ 1)) } asDictionary
]

{ #category : 'aspects' }
BBPlot class >> coverColors [
	"The colors of the types of land cover, as in the figures of the ODD description of the model"

	^ {
		  (#City -> (Color fromHexString: 'D62728')).
		  (#IndusZone -> (Color fromHexString: '9467BD')).
		  (#OpenLand -> (Color fromHexString: '98DF8A')).
		  (#Forest -> (Color fromHexString: '2C7A2C')).
		  (#Agri -> (Color fromHexString: 'F1D54B')).
		  (#Wetland -> (Color fromHexString: '7FD3E8')).
		  (#Sea -> (Color fromHexString: '1F5FBF')).
		  (#BurntArea -> (Color fromHexString: '222222')) } asDictionary
]

{ #category : 'parameters' }
BBPlot class >> densityDependence [
	"The theta of theta-logistic growth: the higher, the later crowding slows growth down"

	<parameterFloatMin: 0.1 max: 5 default: 1.5>
	^ densityDependence
]

{ #category : 'parameters' }
BBPlot class >> densityDependence: aNumber [

	densityDependence := aNumber
]

{ #category : 'parameters' }
BBPlot class >> dispersalSteepness [
	"How sharply dispersal rises as a plot fills up: the higher, the more boars wait until their plot is nearly full"

	<parameterFloatMin: 0.1 max: 20 default: 5>
	^ dispersalSteepness
]

{ #category : 'parameters' }
BBPlot class >> dispersalSteepness: aNumber [

	dispersalSteepness := aNumber
]

{ #category : 'linear features' }
BBPlot class >> edgeCorners [
	"The two corners of the edge of a plot in each direction of the plot table"

	^ {
		  (#N -> #( 3 4 )).
		  (#NE -> #( 4 5 )).
		  (#SE -> #( 5 6 )).
		  (#S -> #( 1 6 )).
		  (#SW -> #( 2 1 )).
		  (#NW -> #( 3 2 )) } asDictionary
]

{ #category : 'parameters' }
BBPlot class >> feedingDensityWeight [

	<parameterFloatMin: 0 max: 1 default: 0.3>
	^ feedingDensityWeight
]

{ #category : 'parameters' }
BBPlot class >> feedingDensityWeight: aNumber [

	feedingDensityWeight := aNumber
]

{ #category : 'habitat' }
BBPlot class >> growthRateReferences [
	"The habitat potential of each type of land cover, before modifiers"

	^ {
		  (#Forest -> 1.0).
		  (#OpenLand -> 0.9).
		  (#Agri -> 0.9).
		  (#Wetland -> 0.8).
		  (#BurntArea -> 0.2).
		  (#Sea -> 0).
		  (#City -> 0.7).
		  (#IndusZone -> 0.5) } asDictionary
]

{ #category : 'habitat' }
BBPlot class >> growthRateWeights [
	"How much each modifier raises habitat potential when it is 1"

	^ {
		  (#acornAvailability -> 0.5).
		  (#wasteAccessibility -> 0.15).
		  (#feedingIntensity -> 0.15) } asDictionary
]

{ #category : 'boars' }
BBPlot class >> initialDensities [
	"The share of the carrying capacity of each type of land cover that boars filled in 1990, before they spread"

	^ {
		  (#Forest -> 0.02).
		  (#OpenLand -> 0.01) } asDictionary
]

{ #category : 'parameters' }
BBPlot class >> maximumDispersalRate [
	"The share of the boars of a full plot that leave it each year when its neighbours are empty"

	<parameterFloatMin: 0 max: 1 default: 0.1>
	^ maximumDispersalRate
]

{ #category : 'parameters' }
BBPlot class >> maximumDispersalRate: aNumber [

	maximumDispersalRate := aNumber
]

{ #category : 'habitat' }
BBPlot class >> modifiers [
	"The selectors of the food sources that make each type of land cover a better habitat"

	^ {
		  (#City -> #( #wasteAccessibility #feedingIntensity )).
		  (#IndusZone -> #( #wasteAccessibility )).
		  (#OpenLand -> #( #acornAvailability )).
		  (#Forest -> #( #acornAvailability )).
		  (#Wetland -> #( #acornAvailability )).
		  (#Agri -> #( #acornAvailability )).
		  (#Sea -> #(  )).
		  (#BurntArea -> #(  )) } asDictionary
]

{ #category : 'parameters' }
BBPlot class >> referenceCarryingCapacity [
	"The number of boars a plot can hold when its habitat quality is 1"

	<parameterFloatMin: 0 max: 100 default: 20>
	^ referenceCarryingCapacity
]

{ #category : 'parameters' }
BBPlot class >> referenceCarryingCapacity: aNumber [

	referenceCarryingCapacity := aNumber
]

{ #category : 'parameters' }
BBPlot class >> referenceGrowthRate [
	"The yearly growth rate of boars on a plot when its habitat potential is 1"

	<parameterFloatMin: 0 max: 2 default: 0.4>
	^ referenceGrowthRate
]

{ #category : 'parameters' }
BBPlot class >> referenceGrowthRate: aNumber [

	referenceGrowthRate := aNumber
]

{ #category : 'parameters' }
BBPlot class >> shrubEncroachmentRate [
	"The share of urban grass that shrubs turn into trees each year from 2018"

	<parameterFloatMin: 0 max: 0.2 default: 0>
	^ shrubEncroachmentRate
]

{ #category : 'parameters' }
BBPlot class >> shrubEncroachmentRate: aNumber [

	shrubEncroachmentRate := aNumber
]

{ #category : 'parameters' }
BBPlot class >> wasteDensityWeight [

	<parameterFloatMin: 0 max: 1 default: 0.6>
	^ wasteDensityWeight
]

{ #category : 'parameters' }
BBPlot class >> wasteDensityWeight: aNumber [

	wasteDensityWeight := aNumber
]

{ #category : 'parameters' }
BBPlot class >> wasteLivingStandardWeight [

	<parameterFloatMin: 0 max: 1 default: 0.4>
	^ wasteLivingStandardWeight
]

{ #category : 'parameters' }
BBPlot class >> wasteLivingStandardWeight: aNumber [

	wasteLivingStandardWeight := aNumber
]

{ #category : 'habitat' }
BBPlot >> acornAvailability [

	^ self cormasModel acornAvailability
]

{ #category : 'linear features' }
BBPlot >> addFeature: aLinearFeature [

	features add: aLinearFeature
]

{ #category : 'accessing' }
BBPlot >> administrativeName [

	^ administrativeName
]

{ #category : 'accessing' }
BBPlot >> administrativeTerritory [

	^ self getAggregateType: BBAdministrativeTerritory
]

{ #category : 'farming' }
BBPlot >> agriculturalUseFactor [
	"Answer how much boars use farmland this year: less when there are many acorns in the woods"

	^ 1
	  -
	  (self class acornDamageReduction * self acornAvailability squared)
]

{ #category : 'aspects' }
BBPlot >> aspectAdministrativeTerritory: look [

	<aspect>
	look colorGroupedBy: administrativeName
]

{ #category : 'aspects' }
BBPlot >> aspectBoars: look [

	<aspect>
	look
		colorShadeOf: (Color fromHexString: '8B4513')
		forValue: boars
		from: 0
		to: 35
]

{ #category : 'aspects' }
BBPlot >> aspectBrushcutting: look [
	"How many brush-cutting campaigns my city has run"

	<aspect>
	look
		colorShadeOf: (self class coverColors at: #Forest)
		forValue: self city brushcuttingCampaigns
		from: 0
		to: 5
]

{ #category : 'aspects' }
BBPlot >> aspectCarryingCapacity: look [

	<aspect>
	look
		colorShadeOf: Color green
		forValue: self carryingCapacity
		from: 0
		to: 35
]

{ #category : 'aspects' }
BBPlot >> aspectDefault: look [
	"The land cover with the largest fraction"

	<aspect>
	look color: (self class coverColors at: landCover mainCover)
]

{ #category : 'aspects' }
BBPlot >> aspectFarmland: look [

	<aspect>
	look
		colorShadeOf: (Color fromHexString: 'E6A600')
		forValue: (landCover fractionOf: #Agri)
		from: 0
		to: 1
]

{ #category : 'aspects' }
BBPlot >> aspectFeedingIntensity: look [

	<aspect>
	look
		colorShadeOf: Color red
		forValue: feedingIntensity
		from: 0
		to: 1
]

{ #category : 'aspects' }
BBPlot >> aspectFeedingPolicy: look [
	"How much my city has cut the feeding of boars by residents"

	<aspect>
	look
		colorShadeOf: Color red
		forValue: self city feedingPolicy
		from: 0
		to: 1
]

{ #category : 'aspects' }
BBPlot >> aspectForest: look [

	<aspect>
	look
		colorShadeOf: (self class coverColors at: #Forest)
		forValue: (landCover fractionOf: #Forest)
		from: 0
		to: 1
]

{ #category : 'aspects' }
BBPlot >> aspectGrowthRate: look [

	<aspect>
	look
		colorShadeOf: Color blue
		forValue: self growthRate
		from: 0
		to: 0.6
]

{ #category : 'aspects' }
BBPlot >> aspectHuntingUnit: look [

	<aspect>
	look colorGroupedBy: huntingUnitName
]

{ #category : 'aspects' }
BBPlot >> aspectInterventions: look [
	"How many times the State services intervened on me"

	<aspect>
	look
		colorShadeOf: Color blue
		forValue: (self cormasModel ddtm interventionsOn: self)
		from: 0
		to: 5
]

{ #category : 'aspects' }
BBPlot >> aspectMunicipality: look [

	<aspect>
	look colorGroupedBy: cityName
]

{ #category : 'aspects' }
BBPlot >> aspectSaturation: look [
	"How full of boars I am, from white when I am empty to red when I am full, and grey when I have no habitat"

	<aspect>
	self carryingCapacity > 0
		ifTrue: [
				look
					colorBetween: Color white
					and: Color red
					forValue: self saturation
					from: 0
					to: 1 ]
		ifFalse: [ look color: Color veryLightGray ]
]

{ #category : 'aspects' }
BBPlot >> aspectUrbanVegetation: look [
	"How much the vegetation inside urban fabric makes it a habitat, on plots with some city"

	<aspect>
	(landCover fractionOf: #City) > 0
		ifTrue: [
				look
					colorShadeOf: (self class coverColors at: #Forest)
					forValue: landCover urbanVegetationScore
					from: 0
					to: 1 ]
		ifFalse: [ look color: Color veryLightGray ]
]

{ #category : 'aspects' }
BBPlot >> aspectWasteAccessibility: look [

	<aspect>
	look
		colorShadeOf: Color orange
		forValue: wasteAccessibility
		from: 0
		to: 1
]

{ #category : 'aspects' }
BBPlot >> aspectWastePolicy: look [
	"How much my city has cut access to household waste"

	<aspect>
	look
		colorShadeOf: Color orange
		forValue: self city wastePolicy
		from: 0
		to: 1
]

{ #category : 'town' }
BBPlot >> associations [

	^ self occupantsOfClass: BBAssociation
]

{ #category : 'dispersal' }
BBPlot >> attractivity [
	"Answer how much I attract dispersing boars: the more room I have, the more, and more again if I am on a river"

	^ self carryingCapacity * (1 - self saturation)
	  * (1 + self edgeAttractivity)
]

{ #category : 'boars' }
BBPlot >> boars [
	"The number of boars on me, which need not be a whole number"

	^ boars
]

{ #category : 'boars' }
BBPlot >> boars: aNumber [

	boars := aNumber
]

{ #category : 'habitat' }
BBPlot >> carryingCapacity [
	"Answer the number of boars I can hold"

	^ self class referenceCarryingCapacity * self habitatQuality
]

{ #category : 'land cover' }
BBPlot >> changeLandCoverIn: aYear [

	landCover changeIn: aYear.
	aYear >= 2018 ifTrue: [
		landCover encroachShrubsBy: self class shrubEncroachmentRate ]
]

{ #category : 'hunting' }
BBPlot >> city [

	^ self cityTerritory city
]

{ #category : 'accessing' }
BBPlot >> cityName [

	^ cityName
]

{ #category : 'accessing' }
BBPlot >> cityTerritory [

	^ self getAggregateType: BBCityTerritory
]

{ #category : 'dispersal' }
BBPlot >> densityDispersalRate [

	| steepness |
	steepness := self class dispersalSteepness.
	^ self class maximumDispersalRate
	  * ((steepness * self saturation) exp - 1) / (steepness exp - 1)
]

{ #category : 'dispersal' }
BBPlot >> densityDispersers [
	"Answer how many boars leave me because I am crowded: more the fuller I am, and the emptier my neighbours are"

	^ boars * self densityDispersalRate * self meanVacancyOfNeighbours
		  min: boars
]

{ #category : 'linear features' }
BBPlot >> edgeAttractivity [
	"Answer how much the features on my edges make me attractive to dispersing boars: the most attractive one counts"

	^ features
		  inject: 0
		  into: [ :maximum :each | maximum max: each attractivityRate ]
]

{ #category : 'farming' }
BBPlot >> farmers [

	^ self occupantsOfClass: BBFarmer
]

{ #category : 'farming' }
BBPlot >> farmlandBoars [
	"Answer how many of my boars live in my farmland, in proportion to what farmland adds to my habitat quality"

	| quality |
	quality := self habitatQuality.
	quality <= 0 ifTrue: [ ^ 0 ].
	^ boars * (self habitatQualityOf: #Agri) / quality
]

{ #category : 'linear features' }
BBPlot >> featuresTowards: aPlot [
	"Answer the roads, highways and rivers on my edge with aPlot, in the order boars meet them"

	^ (features select: [ :each | each plots includes: aPlot ])
		  asSortedCollection: [ :a :b |
		  a class crossingOrder <= b class crossingOrder ]
]

{ #category : 'food' }
BBPlot >> feedingDensityScore [
	"How much the population density leads residents to feed boars, between 0 and 1"

	^ {
		  (#urbanDense -> 1).
		  (#urbanSemiDense -> 0.6).
		  (#ruralLowToVeryLow -> 0.3) } asDictionary
		  at: humanPopDensity
		  ifAbsent: [ 0 ]
]

{ #category : 'food' }
BBPlot >> feedingIntensity [

	^ feedingIntensity
]

{ #category : 'boars' }
BBPlot >> grow [
	"Theta-logistic growth. Overcrowded boars can die out, but never go below zero"

	| capacity |
	capacity := self carryingCapacity.
	capacity <= 0 ifTrue: [ ^ self ].
	boars := boars + (self growthRate * boars
	          *
	          (1
	           -
	           (boars / capacity raisedTo: self class densityDependence)))
		         max: 0
]

{ #category : 'habitat' }
BBPlot >> growthRate [
	"Answer the yearly growth rate of my boars when they are few"

	^ self class referenceGrowthRate * self habitatPotential
]

{ #category : 'habitat' }
BBPlot >> habitatOfTypes: someTypes references: someReferences weights: someWeights [
	"Answer the habitat value of some types of land cover. Each adds its fraction of my area, times its reference value, reduced by the lack of vegetation in urban fabric and raised by the food sources it offers"

	| modifiers |
	modifiers := self class modifiers.
	^ someTypes sum: [ :type |
			  (landCover fractionOf: type) * (someReferences at: type)
			  * (self vegetationFactorOf: type)
			  * ((modifiers at: type) inject: 1 into: [ :product :each |
					   product
					   * (1 + ((self perform: each) * (someWeights at: each))) ]) ]
]

{ #category : 'habitat' }
BBPlot >> habitatPotential [

	^ self
		  habitatOfTypes: BBLandCover types
		  references: self class growthRateReferences
		  weights: self class growthRateWeights
]

{ #category : 'habitat' }
BBPlot >> habitatPotentialOf: aType [
	"Answer the share of my habitat potential that comes from one type of land cover"

	^ self
		  habitatOfTypes: { aType }
		  references: self class growthRateReferences
		  weights: self class growthRateWeights
]

{ #category : 'habitat' }
BBPlot >> habitatQuality [

	^ self
		  habitatOfTypes: BBLandCover types
		  references: self class carryingCapacityReferences
		  weights: self class carryingCapacityWeights
]

{ #category : 'habitat' }
BBPlot >> habitatQualityOf: aType [
	"Answer the share of my habitat quality that comes from one type of land cover"

	^ self
		  habitatOfTypes: { aType }
		  references: self class carryingCapacityReferences
		  weights: self class carryingCapacityWeights
]

{ #category : 'dispersal' }
BBPlot >> huntingDispersers [
	"Answer how many boars the hunts, stands and traps on me scare away"

	^ boars * (self regulations
		   inject: 0
		   into: [ :sum :each | sum + each dispersionPressure ]) min: boars
]

{ #category : 'accessing' }
BBPlot >> huntingUnit [

	^ self getAggregateType: BBHuntingUnit
]

{ #category : 'accessing' }
BBPlot >> huntingUnitName [

	^ huntingUnitName
]

{ #category : 'initialization' }
BBPlot >> initialize [

	super initialize.
	boars := 0.
	arrivingBoars := 0.
	leavingBoars := 0.
	features := OrderedCollection new
]

{ #category : 'initialization' }
BBPlot >> initializeBoars [
	"Boars of 1990 live only in forest and open land, away from towns"

	(self isUrban or: [
		 self neighbourhood anySatisfy: [ :each | each isUrban ] ]) ifTrue: [
		^ boars := 0 ].
	boars := self class referenceCarryingCapacity
	         * (self class initialDensities keys sum: [ :type |
				          (landCover fractionOf: type)
				          * (self class carryingCapacityReferences at: type)
				          * (self class initialDensities at: type) ])
]

{ #category : 'initialization' }
BBPlot >> initializeFromRow: aRow [

	cityName := aRow at: 'cityTerritory'.
	administrativeName := aRow at: 'administrativeTerritory'.
	huntingUnitName := aRow at: 'huntingUnit'.
	humanPopDensity := (aRow at: 'humanPopDensity') asSymbol.
	livingStandard := (aRow at: 'livingStandard') asSymbol.
	initialWasteAccessibility := wasteAccessibility := self class
		                                                   wasteDensityWeight
	                                                   *
	                                                   self
		                                                   wasteDensityScore
	                                                   +
	                                                   (self class
		                                                    wasteLivingStandardWeight
	                                                    *
	                                                    self
		                                                    livingStandardScore)
		                                                   min: 1.
	initialFeedingIntensity := feedingIntensity := self class
		                                               feedingDensityWeight
	                                               *
	                                               self
		                                               feedingDensityScore
		                                               min: 1
]

{ #category : 'hunting' }
BBPlot >> isHuntable [

	^ self isSuitableForHunting and: [ self city isHuntingAllowed ]
]

{ #category : 'hunting' }
BBPlot >> isSuitableForHunting [
	"Answer whether hunters can hunt on me: there must be boars to hunt, and not too many buildings"

	^ self carryingCapacity > 0 and: [ self urbanFraction < 0.5 ]
]

{ #category : 'boars' }
BBPlot >> isUrban [
	"Answer whether my main land cover is built up"

	^ #( #City #IndusZone ) includes: landCover mainCover
]

{ #category : 'linear features' }
BBPlot >> killBoarsBesideRoads [
	"Each road kills some of my boars, if it is mine: a road belongs to the plot with the lower id of the two it lies between"

	features do: [ :each |
		each plots first == self ifTrue: [ each killResidentsOf: self ] ]
]

{ #category : 'accessing' }
BBPlot >> landCover [

	^ landCover
]

{ #category : 'accessing' }
BBPlot >> landCover: aLandCover [

	landCover := aLandCover
]

{ #category : 'town' }
BBPlot >> limitFeedingBy: aPolicy [
	"Reduce the feeding of boars by residents by the share aPolicy, from what it was before any policy"

	feedingIntensity := initialFeedingIntensity * (1 - aPolicy)
]

{ #category : 'town' }
BBPlot >> limitWasteBy: aPolicy [
	"Reduce access to household waste by the share aPolicy, from what it was before any policy"

	wasteAccessibility := initialWasteAccessibility * (1 - aPolicy)
]

{ #category : 'food' }
BBPlot >> livingStandardScore [
	"How much the living standard leaves waste accessible to boars, between 0 and 1: the poorer, the more"

	^ {
		  (#veryLow -> 1).
		  (#low -> 0.8).
		  (#medium -> 0.6).
		  (#high -> 0.4).
		  (#veryHigh -> 0.2) } asDictionary
		  at: livingStandard
		  ifAbsent: [ 0 ]
]

{ #category : 'hunting' }
BBPlot >> loseBoarsKilledBy: someRegulations [

	boars := boars - (someRegulations
		          inject: 0
		          into: [ :sum :each | sum + each boarsKilled ]) max: 0
]

{ #category : 'farming' }
BBPlot >> maximumFarmlandBoars [
	"Answer how many boars my farmland can hold. As in the original model, it divides by my habitat potential rather than my habitat quality"

	| potential |
	potential := self habitatPotential.
	potential <= 0 ifTrue: [ ^ 0 ].
	^ self carryingCapacity * (self habitatQualityOf: #Agri) / potential
]

{ #category : 'dispersal' }
BBPlot >> meanVacancyOfNeighbours [
	"Answer how empty my neighbours are on average, from 0 when they are full to 1 when they are empty"

	| neighbours |
	neighbours := self neighbourhood.
	neighbours isEmpty ifTrue: [ ^ 0 ].
	^ (neighbours sum: [ :each | 1 - each saturation ]) / neighbours size
]

{ #category : 'town' }
BBPlot >> projectedUrbanBoars [
	"Answer how many boars my town will have next year, if they grow as they do now. Unlike growth, the projection can go below zero, as in the original model"

	| capacity nextYear |
	capacity := self carryingCapacity.
	nextYear := capacity <= 0
		            ifTrue: [ boars ]
		            ifFalse: [
				            boars + (self growthRate * boars
				             *
				             (1
				              -
				              (boars / capacity raisedTo:
					               self class densityDependence))) ].
	^ self urbanShareOf: nextYear
]

{ #category : 'town' }
BBPlot >> projectedUrbanBoarsAfter: aChangeBlock [
	"Answer the projected urban boars if aChangeBlock changed my food or my urban vegetation. I am left as I was"

	| waste feeding trees grass |
	waste := wasteAccessibility.
	feeding := feedingIntensity.
	trees := landCover urbanTrees.
	grass := landCover urbanGrass.
	^ [
		  aChangeBlock value: self.
		  self projectedUrbanBoars ] ensure: [
			  wasteAccessibility := waste.
			  feedingIntensity := feeding.
			  landCover urbanTrees: trees grass: grass ]
]

{ #category : 'dispersal' }
BBPlot >> receiveDispersers: aNumber [

	arrivingBoars := arrivingBoars + aNumber
]

{ #category : 'hunting' }
BBPlot >> regulations [
	"Answer the hunts, stands and traps on me"

	^ self occupantsOfClass: BBRegulation
]

{ #category : 'dispersal' }
BBPlot >> resetDispersal [

	arrivingBoars := 0.
	leavingBoars := 0
]

{ #category : 'boars' }
BBPlot >> saturation [
	"Answer how full I am, from 0 when I have no boars to 1 when I hold as many as I can. A plot with no habitat counts as full"

	| capacity |
	capacity := self carryingCapacity.
	capacity <= 0 ifTrue: [ ^ 1 ].
	^ boars / capacity min: 1 max: 0
]

{ #category : 'dispersal' }
BBPlot >> sendDispersers: aNumber [
	"Share aNumber of my boars among my neighbours that have a habitat and are not more crowded than me, in proportion to their attractivity. They stay if there is no such neighbour. Roads, highways and rivers on the way stop or kill some of them, and the stopped ones leave through the edges that stopped nobody. If every edge stopped some, the stopped boars are lost, as in the original model"

	| welcoming totalAttractivity crossing stopped escapes |
	aNumber > 0 ifFalse: [ ^ self ].
	welcoming := self neighbourhood select: [ :each |
		             each carryingCapacity > 0 and: [
			             each saturation <= self saturation ] ].
	totalAttractivity := welcoming
		                     inject: 0
		                     into: [ :sum :each | sum + each attractivity ].
	totalAttractivity > 0 ifFalse: [ ^ self ].
	crossing := Dictionary new.
	stopped := Dictionary new.
	welcoming do: [ :each |
			| boarsOnTheWay stoppedOnTheWay |
			boarsOnTheWay := each attractivity / totalAttractivity * aNumber.
			stoppedOnTheWay := 0.
			(self featuresTowards: each) do: [ :feature |
					stoppedOnTheWay := stoppedOnTheWay
					                   + (feature stopped: boarsOnTheWay).
					boarsOnTheWay := feature cross: boarsOnTheWay ].
			crossing at: each put: boarsOnTheWay.
			stopped at: each put: stoppedOnTheWay ].
	escapes := welcoming select: [ :each | (stopped at: each) = 0 ].
	escapes do: [ :each |
			crossing
				at: each
				put: (crossing at: each) + (stopped sum / escapes size) ].
	crossing keysAndValuesDo: [ :neighbour :boarsArriving |
		neighbour receiveDispersers: boarsArriving ].
	leavingBoars := leavingBoars + aNumber
]

{ #category : 'dispersal' }
BBPlot >> settleDispersers [

	boars := boars - leavingBoars + arrivingBoars max: 0
]

{ #category : 'hunting' }
BBPlot >> urbanFraction [

	^ (landCover fractionOf: #City) + (landCover fractionOf: #IndusZone)
]

{ #category : 'town' }
BBPlot >> urbanSaturation [
	"Answer how full of boars my town is, compared with how many it could hold. It is 0 when my town holds none"

	| maximum |
	maximum := self urbanShareOf: self carryingCapacity.
	maximum <= 0 ifTrue: [ ^ 0 ].
	^ (self urbanShareOf: boars) / maximum
]

{ #category : 'town' }
BBPlot >> urbanShareOf: aNumberOfBoars [
	"Answer how many of aNumberOfBoars on me would be in my town, in proportion to what the city adds to my habitat quality, and fewer in a good acorn year"

	| quality |
	quality := self habitatQuality.
	quality <= 0 ifTrue: [ ^ 0 ].
	^ aNumberOfBoars * (self habitatQualityOf: #City) / quality
	  * self urbanUseFactor
]

{ #category : 'town' }
BBPlot >> urbanUseFactor [
	"Answer how much boars use towns this year: less when there are many acorns in the woods"

	^ 1
	  - (self class acornUrbanReduction * self acornAvailability squared)
]

{ #category : 'habitat' }
BBPlot >> vegetationFactorOf: aType [

	^ (#( #City #IndusZone ) includes: aType)
		  ifTrue: [ landCover urbanVegetationScore ]
		  ifFalse: [ 1 ]
]

{ #category : 'food' }
BBPlot >> wasteAccessibility [

	^ wasteAccessibility
]

{ #category : 'food' }
BBPlot >> wasteDensityScore [
	"How much household waste the population density leaves for boars, between 0 and 1"

	^ {
		  (#urbanDense -> 1).
		  (#urbanSemiDense -> 0.8).
		  (#ruralLowToVeryLow -> 0.5) } asDictionary
		  at: humanPopDensity
		  ifAbsent: [ 0 ]
]
