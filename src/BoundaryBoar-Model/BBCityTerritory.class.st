"
I am the territory of a municipality, named after it in the plot table, such as 'MONTPELLIER'. My `city` manages me. My probe `urbanBoars` measures the boars of my town itself. See `BBTerritory`.
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

{ #category : 'charts' }
BBCityTerritory >> chartUrbanBoars [
	"How many of my boars live in the town itself?"

	<chart>
	^ CMChart new
		  title: 'Boars of the town';
		  add: (CMLineSeries new
				   x: #currentTimeStep y: #boars;
				   label: 'All boars';
				   yourself);
		  add: (CMLineSeries new
				   x: #currentTimeStep y: #urbanBoars;
				   label: 'Urban boars';
				   yourself);
		  yourself
]

{ #category : 'accessing' }
BBCityTerritory >> city [
	"Answer the municipality that manages me"

	^ city
]

{ #category : 'accessing' }
BBCityTerritory >> city: aCity [

	city := aCity
]

{ #category : 'probes' }
BBCityTerritory >> urbanBoars [

	<probe>
	^ self components sum: [ :each | each urbanBoars ]
]
