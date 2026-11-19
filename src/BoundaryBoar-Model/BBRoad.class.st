"
I am a road on the edge between two plots. Half the boars that meet me cross me, and cars kill 5 % of those. Every year, cars also kill 0.5 % of the boars living on the plot I belong to, the one with the lower id. I count the boars killed this year. See `BBLinearFeature`.

```
road cross: 10. ""4.75""
road collisions. ""0.25""
```
"
Class {
	#name : 'BBRoad',
	#superclass : 'BBLinearFeature',
	#instVars : [
		'collisions'
	],
	#classInstVars : [
		'crossingMortality',
		'residentMortality'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBRoad class >> crossingMortality [
	"The share of the boars crossing a road that are killed by cars"

	<parameterFloatMin: 0 max: 1 default: 0.05>
	^ crossingMortality
]

{ #category : 'accessing' }
BBRoad class >> crossingMortality: aNumber [

	crossingMortality := aNumber
]

{ #category : 'accessing' }
BBRoad class >> crossingOrder [

	^ 2
]

{ #category : 'accessing' }
BBRoad class >> letter [

	^ $R
]

{ #category : 'accessing' }
BBRoad class >> residentMortality [
	"The yearly share of the boars living beside a road that are killed by cars"

	<parameterFloatMin: 0 max: 1 default: 0.005>
	^ residentMortality
]

{ #category : 'accessing' }
BBRoad class >> residentMortality: aNumber [

	residentMortality := aNumber
]

{ #category : 'aspects' }
BBRoad >> aspectCollisions: look [
	"The boars killed by cars on me this year, from grey for none to red for one or more"

	<aspect>
	super aspectDefault: look.
	look
		colorBetween: Color lightGray
		and: Color red
		forValue: collisions
		from: 0
		to: 1;
		thicknessForValue: collisions from: 0 to: 1
]

{ #category : 'aspects' }
BBRoad >> aspectDefault: look [

	<aspect>
	super aspectDefault: look.
	look
		color: Color darkGray;
		thickness: 2
]

{ #category : 'crossing' }
BBRoad >> collisions [
	"The number of boars killed by cars on me this year"

	^ collisions
]

{ #category : 'crossing' }
BBRoad >> cross: aNumber [
	"Some of the boars that cross me are killed by cars"

	| crossing killed |
	crossing := super cross: aNumber.
	killed := crossing * self class crossingMortality.
	collisions := collisions + killed.
	^ crossing - killed
]

{ #category : 'crossing' }
BBRoad >> initialize [

	super initialize.
	collisions := 0
]

{ #category : 'crossing' }
BBRoad >> killResidentsOf: aPlot [

	| killed |
	killed := aPlot boars * self class residentMortality.
	collisions := collisions + killed.
	aPlot boars: aPlot boars - killed
]

{ #category : 'crossing' }
BBRoad >> permeability [

	^ 0.5
]

{ #category : 'crossing' }
BBRoad >> resetCollisions [

	collisions := 0
]
