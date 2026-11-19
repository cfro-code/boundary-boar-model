"
I am a hexagonal plot of the landscape around Montpellier. I know my land cover, the municipality, administrative territory and hunting unit I belong to, and how much anthropogenic food boars find on me.

## Responsibility:

- Read my attributes from a row of the plot table: the names of my territories, my human population density and my living standard.
- Know how accessible household waste is and how much residents feed boars, now and at the start.
- Hold my `BBLandCover` and answer the territories I belong to.

## Collaborators:

- `BBModel` creates me from the plot table and gives me my land cover.
- `BBLandCover` holds the fractions of my area under each type of land cover.
- `BBCityTerritory`, `BBAdministrativeTerritory` and `BBHuntingUnit` are the territories I belong to.

## Public API and Key Messages

- `wasteAccessibility` and `feedingIntensity` answer the anthropogenic food on me, between 0 and 1.
- `landCover` answers my land cover.
- `cityTerritory`, `administrativeTerritory` and `huntingUnit` answer my territories.
- The weights of density and living standard are parameters of my class.

```
plot := model cellAt: 5 at: 12.
plot wasteAccessibility. ""0.64 for a semi-dense area with a high living standard""
plot landCover mainCover. ""#City""
```

## Internal Representation

- `humanPopDensity` is `#urbanDense`, `#urbanSemiDense`, `#ruralLowToVeryLow` or `#noPop`.
- `livingStandard` is `#veryLow`, `#low`, `#medium`, `#high`, `#veryHigh` or `#NA`.
- `initialWasteAccessibility` and `initialFeedingIntensity` are the values before any city policy; `wasteAccessibility` and `feedingIntensity` are the current ones.
- `cityName`, `administrativeName` and `huntingUnitName` are the names my territories are created from.

### Implementation Points

As in the original model, the initial feeding intensity depends only on the population density: the share of residents who like boars is not known yet when it is computed, because associations do not exist yet. The original also had a grain feeding intensity, always 0, which is left out.
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
		'landCover'
	],
	#classInstVars : [
		'wasteDensityWeight',
		'wasteLivingStandardWeight',
		'feedingDensityWeight'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBPlot class >> feedingDensityWeight [

	<parameterFloatMin: 0 max: 1 default: 0.3>
	^ feedingDensityWeight
]

{ #category : 'parameters' }
BBPlot class >> feedingDensityWeight: aNumber [

	feedingDensityWeight := aNumber
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

{ #category : 'accessing' }
BBPlot >> administrativeName [

	^ administrativeName
]

{ #category : 'accessing' }
BBPlot >> administrativeTerritory [

	^ self getAggregateType: BBAdministrativeTerritory
]

{ #category : 'accessing' }
BBPlot >> cityName [

	^ cityName
]

{ #category : 'accessing' }
BBPlot >> cityTerritory [

	^ self getAggregateType: BBCityTerritory
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

{ #category : 'accessing' }
BBPlot >> huntingUnit [

	^ self getAggregateType: BBHuntingUnit
]

{ #category : 'accessing' }
BBPlot >> huntingUnitName [

	^ huntingUnitName
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

{ #category : 'accessing' }
BBPlot >> landCover [

	^ landCover
]

{ #category : 'accessing' }
BBPlot >> landCover: aLandCover [

	landCover := aLandCover
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
