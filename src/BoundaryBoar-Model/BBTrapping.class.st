"
I am a trapping campaign of the State services in dense town, for one year. I catch 70 % of the boars of my plot and scare away 5 %, both parameters of my class. I hunt after driven hunts and stands. See `BBRegulation`.
"
Class {
	#name : 'BBTrapping',
	#superclass : 'BBRegulation',
	#classInstVars : [
		'lethality',
		'dispersionPressure'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBTrapping class >> dispersionPressure [
	"The share of the boars of its plot that a trapping campaign scares away"

	<parameterFloatMin: 0 max: 1 default: 0.05>
	^ dispersionPressure
]

{ #category : 'parameters' }
BBTrapping class >> dispersionPressure: aNumber [

	dispersionPressure := aNumber
]

{ #category : 'parameters' }
BBTrapping class >> lethality [
	"The share of the boars of its plot that a trapping campaign catches"

	<parameterFloatMin: 0 max: 1 default: 0.7>
	^ lethality
]

{ #category : 'parameters' }
BBTrapping class >> lethality: aNumber [

	lethality := aNumber
]

{ #category : 'aspects' }
BBTrapping >> aspectDefault: look [

	<aspect>
	look
		color: Color black;
		shape: #square;
		size: 0.3
]
