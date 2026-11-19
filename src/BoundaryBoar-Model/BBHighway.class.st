"
I am a fenced highway on the edge between two plots: no boar crosses me. See `BBLinearFeature`.
"
Class {
	#name : 'BBHighway',
	#superclass : 'BBLinearFeature',
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBHighway class >> crossingOrder [

	^ 1
]

{ #category : 'accessing' }
BBHighway class >> letter [

	^ $H
]

{ #category : 'aspects' }
BBHighway >> aspectDefault: look [

	<aspect>
	super aspectDefault: look.
	look
		color: Color red;
		thickness: 3
]

{ #category : 'crossing' }
BBHighway >> permeability [
	"Highways are fenced: no boar crosses them"

	^ 0
]
