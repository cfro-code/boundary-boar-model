"
I am the territory of a municipality, named after it in the plot table, such as 'MONTPELLIER'. My `city` manages me. See `BBTerritory`.
"
Class {
	#name : 'BBCityTerritory',
	#superclass : 'BBTerritory',
	#instVars : [
		'city'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBCityTerritory >> city [
	"Answer the municipality that manages me"

	^ city
]

{ #category : 'accessing' }
BBCityTerritory >> city: aCity [

	city := aCity
]
