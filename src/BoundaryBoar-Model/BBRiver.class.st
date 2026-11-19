"
I am a river on the edge between two plots. Boars swim across me, and plots beside me attract dispersing boars more, by my class parameter `attractivityRate`. See `BBLinearFeature`.
"
Class {
	#name : 'BBRiver',
	#superclass : 'BBLinearFeature',
	#classInstVars : [
		'attractivityRate'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBRiver class >> attractivityRate [
	"How much more attractive a plot on a river is to dispersing boars"

	<parameterFloatMin: 0 max: 5 default: 1>
	^ attractivityRate
]

{ #category : 'accessing' }
BBRiver class >> attractivityRate: aNumber [

	attractivityRate := aNumber
]

{ #category : 'accessing' }
BBRiver class >> crossingOrder [

	^ 3
]

{ #category : 'accessing' }
BBRiver class >> letter [

	^ $W
]

{ #category : 'aspects' }
BBRiver >> aspectDefault: look [

	<aspect>
	super aspectDefault: look.
	look
		color: (Color fromHexString: '1E64C8');
		thickness: 2
]

{ #category : 'crossing' }
BBRiver >> permeability [
	"Boars swim across rivers"

	^ 1
]
