"
I am a stand (affût) that a farmer sets up on their plot for one year, when boars threaten their crop heavily. I kill 40 % of the boars in the farmland of my farmer, and scare away 10 % of the boars of my plot, both parameters of my class. See `BBRegulation`.
"
Class {
	#name : 'BBStand',
	#superclass : 'BBRegulation',
	#classInstVars : [
		'lethality',
		'dispersionPressure'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBStand class >> dispersionPressure [
	"The share of the boars of its plot that a stand scares away"

	<parameterFloatMin: 0 max: 1 default: 0.1>
	^ dispersionPressure
]

{ #category : 'parameters' }
BBStand class >> dispersionPressure: aNumber [

	dispersionPressure := aNumber
]

{ #category : 'parameters' }
BBStand class >> lethality [
	"The share of the boars it can reach that a stand kills"

	<parameterFloatMin: 0 max: 1 default: 0.4>
	^ lethality
]

{ #category : 'parameters' }
BBStand class >> lethality: aNumber [

	lethality := aNumber
]

{ #category : 'aspects' }
BBStand >> aspectDefault: look [

	<aspect>
	look
		color: Color blue;
		shape: #diamond;
		size: 0.3
]

{ #category : 'hunting' }
BBStand >> hunt [
	"Kill my share of the boars my organizer exposes to me, at most all the boars of my plot"

	boarsKilled := (organizer boarsExposedToStandOn: self cell)
	               * self lethality min: self cell boars
]
