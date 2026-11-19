"
I am a farmer who grows grain. See `BBFarmer`.
"
Class {
	#name : 'BBGrainFarmer',
	#superclass : 'BBFarmer',
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBGrainFarmer class >> crop [

	^ #grain
]

{ #category : 'aspects' }
BBGrainFarmer class >> cropColor [

	^ Color fromHexString: 'D4A017'
]

{ #category : 'parameters' }
BBGrainFarmer class >> damageSensitivity [
	"How much boars damage my crop"

	<parameterFloatMin: 0 max: 1 default: 0.4>
	^ damageSensitivity
]

{ #category : 'parameters' }
BBGrainFarmer class >> fencingProbability [
	"The probability that a farmer growing my crop can afford permanent fences"

	<parameterFloatMin: 0 max: 1 default: 0.2>
	^ fencingProbability
]
