"
I am a farmer who grows vines. See `BBFarmer`.
"
Class {
	#name : 'BBWineGrower',
	#superclass : 'BBFarmer',
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBWineGrower class >> crop [

	^ #wine
]

{ #category : 'aspects' }
BBWineGrower class >> cropColor [

	^ Color fromHexString: '7B2D8E'
]

{ #category : 'parameters' }
BBWineGrower class >> damageSensitivity [
	"How much boars damage my crop"

	<parameterFloatMin: 0 max: 1 default: 0.5>
	^ damageSensitivity
]

{ #category : 'parameters' }
BBWineGrower class >> fencingProbability [
	"The probability that a farmer growing my crop can afford permanent fences"

	<parameterFloatMin: 0 max: 1 default: 0.6>
	^ fencingProbability
]
