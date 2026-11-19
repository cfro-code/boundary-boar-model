"
I am a neighbourhood association on a plot of dense town. My residents have three attitudes towards boars, coexistence, ambivalent and worried, and would like their town to be more or less full of boars. Every year I compare the boars in our town with what they would like.

## Responsibility:

- Know the shares of the attitudes of my residents, and how full of boars they would like their town to be.
- Measure every year how satisfied they are, and remember the last three years.
- Tell my city whether my residents complain.

## Collaborators:

- `BBPlot`: my plot, which tells how full of boars its town is.
- `BBCity` asks me whether my residents complain.

## Public API and Key Messages

- `preferredSaturation` and `perceivedSaturation`.
- `assessSatisfaction` and `satisfaction`, from 0 to 1.
- `isDissatisfied`: satisfaction is below a threshold, a parameter of my class, because boars are too many.

```
association := (model cellAt: 9 at: 12) associations first.
association preferredSaturation. ""0.29 in Montpellier Méditerranée Métropole""
```

## Internal Representation

- `profile` maps `#coexistence`, `#ambivalent` and `#worried` to their shares.
- `satisfactionHistory` holds the last three satisfactions, the latest last.

### Implementation Points

The perceived saturation is the boars in the town of my plot divided by the most it could hold, which is 0 when it can hold none. The original divided by zero there.
"
Class {
	#name : 'BBAssociation',
	#superclass : 'CMAgent',
	#instVars : [
		'profile',
		'satisfaction',
		'satisfactionHistory'
	],
	#classInstVars : [
		'dissatisfactionThreshold'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBAssociation class >> dissatisfactionThreshold [
	"The satisfaction below which residents complain, if boars are too many for them"

	<parameterFloatMin: 0 max: 1 default: 0.6>
	^ dissatisfactionThreshold
]

{ #category : 'parameters' }
BBAssociation class >> dissatisfactionThreshold: aNumber [

	dissatisfactionThreshold := aNumber
]

{ #category : 'parameters' }
BBAssociation class >> preferredSaturations [
	"How full of boars residents of each attitude would like their town to be"

	^ {
		  (#coexistence -> 0.5).
		  (#ambivalent -> 0.2).
		  (#worried -> 0) } asDictionary
]

{ #category : 'aspects' }
BBAssociation >> aspectDefault: look [
	"A circle, from red when my residents are not satisfied at all to green when they are fully satisfied"

	<aspect>
	look
		colorBetween: Color red
		and: Color green
		forValue: satisfaction
		from: 0
		to: 1;
		shape: #circle;
		size: 0.3
]

{ #category : 'satisfaction' }
BBAssociation >> assessSatisfaction [
	"The further boars in my town are from what my residents would like, the less satisfied they are. Remember the last three years"

	satisfaction := 1
	                -
	                (self perceivedSaturation - self preferredSaturation)
		                abs min: 1 max: 0.
	satisfactionHistory add: satisfaction.
	satisfactionHistory size > 3 ifTrue: [
		satisfactionHistory removeFirst ]
]

{ #category : 'initialization' }
BBAssociation >> initialize [

	super initialize.
	satisfaction := 0.
	satisfactionHistory := OrderedCollection new
]

{ #category : 'satisfaction' }
BBAssociation >> isDissatisfied [
	"Answer whether my residents complain: they are not satisfied, because boars are too many"

	^ satisfaction < self class dissatisfactionThreshold and: [
		  self perceivedSaturation > self preferredSaturation ]
]

{ #category : 'satisfaction' }
BBAssociation >> perceivedSaturation [

	^ self cell urbanSaturation
]

{ #category : 'satisfaction' }
BBAssociation >> preferredSaturation [
	"Answer how full of boars my residents would like their town to be"

	^ profile keys sum: [ :attitude |
			  (profile at: attitude)
			  * (self class preferredSaturations at: attitude) ]
]

{ #category : 'initialization' }
BBAssociation >> profile: aDictionary [
	"Have residents of each attitude, #coexistence, #ambivalent and #worried, in the shares of aDictionary"

	profile := aDictionary
]

{ #category : 'satisfaction' }
BBAssociation >> satisfaction [

	^ satisfaction
]
