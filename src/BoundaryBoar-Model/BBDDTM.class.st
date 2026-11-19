"
I am the State services of the department (DDTM). From 2019, cities ask me to intervene on town plots overrun by boars, and farmers who may not hunt ask me to intervene on their plot. I intervene a few times a year, a parameter of my class, for cities first.

## Responsibility:

- Collect the requests of the year from cities and farmers.
- Intervene on the most overrun town plots first, then for the most damaged farmers, as many times as I can.
- Choose my means from the landscape: a driven hunt where hunters can hunt, whether hunting is allowed or not, traps in dense town, a stand in between.

## Collaborators:

- `BBCity` and `BBFarmer` ask me to intervene.
- `BBDrivenHunt`, `BBStand` and `BBTrapping`: my interventions, which last one year.

## Public API and Key Messages

- `requestInterventionOn: aPlot` and `requestInterventionFor: aFarmer` receive requests; `intervene` answers them.
- `interveneOn: aPlot` intervenes once.
- `interventionsOn: aPlot` answers how many times I intervened there.

```
model ddtm interveneOn: (model cellAt: 9 at: 12). ""a BBStand: 80 % of this plot of Montpellier is built up, not quite enough for traps""
```

## Internal Representation

- `cityRequests` and `farmerRequests` hold the requests of the year, forgotten once I intervened.
- `interventionsForCities` and `interventionsForFarmers` count my interventions on each plot.

### Implementation Points

As the original model probably intended, my interventions kill boars and are removed at the start of the next year. The original created them without registering them in the model, so they killed nothing and piled up.
"
Class {
	#name : 'BBDDTM',
	#superclass : 'CMAgent',
	#instVars : [
		'cityRequests',
		'farmerRequests',
		'interventionsForCities',
		'interventionsForFarmers'
	],
	#classInstVars : [
		'interventionCapacity'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBDDTM class >> interventionCapacity [
	"The number of interventions the DDTM can make each year"

	<parameterIntegerMin: 0 max: 100 default: 5>
	^ interventionCapacity
]

{ #category : 'parameters' }
BBDDTM class >> interventionCapacity: anInteger [

	interventionCapacity := anInteger
]

{ #category : 'interventions' }
BBDDTM >> boarsExposedToStandOn: aPlot [
	"My stands shoot among all the boars of their plot"

	^ aPlot boars
]

{ #category : 'initialization' }
BBDDTM >> initialize [

	super initialize.
	cityRequests := OrderedCollection new.
	farmerRequests := OrderedCollection new.
	interventionsForCities := Bag new.
	interventionsForFarmers := Bag new
]

{ #category : 'interventions' }
BBDDTM >> intervene [
	"Intervene as often as I can this year: first for cities, on the most overrun town plots, then for farmers, the most damaged first. Then forget the requests"

	| forCities forFarmers |
	forCities := (cityRequests sorted: [ :a :b |
			              a associations first perceivedSaturation
			              >= b associations first perceivedSaturation ])
		             first:
		             (self class interventionCapacity min: cityRequests size).
	forCities do: [ :each |
			self interveneOn: each.
			interventionsForCities add: each ].
	forFarmers := (farmerRequests sorted: [ :a :b | a damage >= b damage ])
		              first:
			              (self class interventionCapacity - forCities size
				               min: farmerRequests size).
	forFarmers do: [ :each |
			self interveneOn: each cell.
			interventionsForFarmers add: each cell ].
	cityRequests := OrderedCollection new.
	farmerRequests := OrderedCollection new
]

{ #category : 'interventions' }
BBDDTM >> interveneOn: aPlot [
	"Organize a driven hunt where hunters can hunt, whether hunting is allowed or not, traps in dense town, and a stand in between"

	^ (self cormasModel
		   newEntity: (self meansFor: aPlot)
		   locatedAt: aPlot)
		  organizer: self;
		  yourself
]

{ #category : 'interventions' }
BBDDTM >> interventionsOn: aPlot [
	"Answer how many times I intervened on aPlot, for cities and for farmers"

	^ (interventionsForCities occurrencesOf: aPlot)
	  + (interventionsForFarmers occurrencesOf: aPlot)
]

{ #category : 'interventions' }
BBDDTM >> keepsItsRegulations [
	"My interventions last one year"

	^ false
]

{ #category : 'interventions' }
BBDDTM >> meansFor: aPlot [

	aPlot isSuitableForHunting ifTrue: [ ^ BBDrivenHunt ].
	aPlot urbanFraction > 0.8 ifTrue: [ ^ BBTrapping ].
	^ BBStand
]

{ #category : 'interventions' }
BBDDTM >> requestInterventionFor: aFarmer [

	farmerRequests add: aFarmer
]

{ #category : 'interventions' }
BBDDTM >> requestInterventionOn: aPlot [
	"A city asks me to intervene on a town plot overrun by boars"

	cityRequests add: aPlot
]
