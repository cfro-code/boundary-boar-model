"
I am the land cover of one plot: the fraction of its area under each type of cover, now and at the dates observed from 1990 to 2018, with the vegetation inside its urban fabric and the crops of its farmland.

## Responsibility:

- Read the observed fractions of a plot from a row of the cover table, with decimal commas and empty fields as zero.
- Know the current fraction of each type and which type covers the most area.
- Know the trees and grass inside urban fabric, and the shares of vineyards, grain and vegetables in farmland.

## Collaborators:

- `BBPlot` holds me.
- `BBModel` creates me from the cover table.

## Public API and Key Messages

- `BBLandCover fromRow: aDictionary` creates me from a row of the cover table.
- `fractionOf: #Forest` answers the current fraction of a type.
- `fractionOf: #City in: 2018` answers an observed fraction.
- `mainCover` answers the type with the largest fraction.
- `urbanTrees`, `urbanGrass` and `agriculturalShareOf: #wine` answer the vegetation and crops.

```
cover := BBLandCover fromRow: aRowOfTheCoverTable.
cover fractionOf: #Forest. ""0.75""
cover mainCover. ""#Forest""
```

## Internal Representation

- `fractions` maps each of the types answered by `BBLandCover types` to its current fraction. The fractions add up to at most 1.
- `history` maps each observed year, 1990, 2000, 2006, 2012 and 2018, to the fractions of that year.
- `urbanTrees` and `urbanGrass` are between 0 and 1, and 0 when the table gives none. The initial values are kept for shrub encroachment.
- `agriculturalShares` maps `#wine`, `#grain` and `#vegetables` to their share of the farmland.

### Implementation Points

I start from a copy of the 1990 fractions, so changing the current cover never changes the record of 1990.
"
Class {
	#name : 'BBLandCover',
	#superclass : 'Object',
	#instVars : [
		'fractions',
		'history',
		'urbanTrees',
		'urbanGrass',
		'initialUrbanTrees',
		'initialUrbanGrass',
		'agriculturalShares'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'instance creation' }
BBLandCover class >> fromRow: aDictionary [

	^ self new
		  initializeFromRow: aDictionary;
		  yourself
]

{ #category : 'accessing' }
BBLandCover class >> numberIn: aString [
	"Read a number of the cover table, where decimals have a comma and an empty field means zero"

	^ aString isEmpty
		  ifTrue: [ 0 ]
		  ifFalse: [ (aString copyReplaceAll: ',' with: '.') asNumber ]
]

{ #category : 'accessing' }
BBLandCover class >> observedYears [

	^ #( 1990 2000 2006 2012 2018 )
]

{ #category : 'accessing' }
BBLandCover class >> types [
	"The types of land cover, in the order used to break ties"

	^ #( #City #IndusZone #OpenLand #Forest #Agri #Wetland #Sea #BurntArea )
]

{ #category : 'accessing' }
BBLandCover >> agriculturalShareOf: aCrop [
	"Answer the share of the farmland given to #wine, #grain or #vegetables"

	^ agriculturalShares at: aCrop
]

{ #category : 'accessing' }
BBLandCover >> fractionOf: aType [

	^ fractions at: aType
]

{ #category : 'accessing' }
BBLandCover >> fractionOf: aType in: aYear [
	"Answer the fraction observed in one of the years answered by BBLandCover observedYears"

	^ (history at: aYear) at: aType
]

{ #category : 'initialization' }
BBLandCover >> fractionsIn: aYear fromRow: aRow [
	"Columns are named after the type and the last two digits of the year, such as coverForest_06"

	| suffix |
	suffix := aYear \\ 100 printPaddedWith: $0 to: 2.
	^ (self class types collect: [ :type |
			   type
			   ->
			   (self class numberIn: (aRow at: 'cover' , type , '_' , suffix)) ])
		  asDictionary
]

{ #category : 'initialization' }
BBLandCover >> initializeFromRow: aRow [

	history := Dictionary new.
	self class observedYears do: [ :year |
		history at: year put: (self fractionsIn: year fromRow: aRow) ].
	fractions := (history at: 1990) copy.
	urbanTrees := initialUrbanTrees := self class numberIn:
		                                   (aRow at: 'treeCity').
	urbanGrass := initialUrbanGrass := self class numberIn:
		                                   (aRow at: 'grassCity').
	agriculturalShares := Dictionary new.
	agriculturalShares
		at: #wine put: (self class numberIn: (aRow at: 'wine'));
		at: #grain put: (self class numberIn: (aRow at: 'grain'));
		at: #vegetables put: (self class numberIn: (aRow at: 'vegetable'))
]

{ #category : 'accessing' }
BBLandCover >> mainCover [
	"Answer the type with the largest fraction"

	^ self class types detectMax: [ :each | self fractionOf: each ]
]

{ #category : 'accessing' }
BBLandCover >> urbanGrass [

	^ urbanGrass
]

{ #category : 'accessing' }
BBLandCover >> urbanTrees [

	^ urbanTrees
]
