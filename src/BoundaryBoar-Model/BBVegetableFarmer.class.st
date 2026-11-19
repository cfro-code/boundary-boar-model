"
I am a farmer who grows vegetables, which boars damage most. See `BBFarmer`.
"
Class {
	#name : 'BBVegetableFarmer',
	#superclass : 'BBFarmer',
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBVegetableFarmer class >> crop [

	^ #vegetables
]

{ #category : 'aspects' }
BBVegetableFarmer class >> cropColor [

	^ Color fromHexString: '3A9D23'
]

{ #category : 'parameters' }
BBVegetableFarmer class >> damageSensitivity [
	"How much boars damage my crop"

	<parameterFloatMin: 0 max: 1 default: 0.9>
	^ damageSensitivity
]

{ #category : 'parameters' }
BBVegetableFarmer class >> fencingProbability [
	"The probability that a farmer growing my crop can afford permanent fences"

	<parameterFloatMin: 0 max: 1 default: 0.8>
	^ fencingProbability
]
