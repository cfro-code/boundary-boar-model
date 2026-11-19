"
I am a driven hunt (battue) on one plot. I kill 10 % of the boars of my plot and scare away 30 % of them, both parameters of my class. Local hunting groups organize me and keep me from year to year. See `BBRegulation`.
"
Class {
	#name : 'BBDrivenHunt',
	#superclass : 'BBRegulation',
	#classInstVars : [
		'lethality',
		'dispersionPressure'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBDrivenHunt class >> dispersionPressure [
	"The share of the boars of its plot that a driven hunt scares away"

	<parameterFloatMin: 0 max: 1 default: 0.3>
	^ dispersionPressure
]

{ #category : 'parameters' }
BBDrivenHunt class >> dispersionPressure: aNumber [

	dispersionPressure := aNumber
]

{ #category : 'parameters' }
BBDrivenHunt class >> lethality [
	"The share of the boars of its plot that a driven hunt kills"

	<parameterFloatMin: 0 max: 1 default: 0.1>
	^ lethality
]

{ #category : 'parameters' }
BBDrivenHunt class >> lethality: aNumber [

	lethality := aNumber
]

{ #category : 'aspects' }
BBDrivenHunt >> aspectBag: look [
	"Larger the more boars I killed in the last hunt"

	<aspect>
	self aspectDefault: look.
	look sizeForValue: boarsKilled from: 0 to: 3
]

{ #category : 'aspects' }
BBDrivenHunt >> aspectDefault: look [

	<aspect>
	look
		color: Color orange;
		shape: #triangle;
		size: 0.4
]
