"
I am a road, a highway or a river on the edge between two neighbouring plots. Boars that disperse across my edge meet me: some turn back, some cross, and some may die.

## Responsibility:

- Connect two neighbouring plots, with no direction.
- Tell how many of the boars that meet me turn back, and how many reach the other side alive.
- Tell which letter stands for me in the edge codes of the plot table, and in which order boars meet me on an edge with several features.

## Collaborators:

- `BBModel` creates one of me per edge and type from the edge codes of the plot table.
- `BBPlot` asks the features on its edge with a neighbour to let its dispersing boars through.

## Public API and Key Messages

- `BBLinearFeature forLetter: $R` answers the class of a letter of the edge codes: `$R` for `BBRoad`, `$H` for `BBHighway`, `$W` for `BBRiver`.
- `stopped: aNumber` answers how many of aNumber boars turn back, and `cross: aNumber` how many reach the other side alive.
- `permeability` answers the share of the boars that cross me.

```
road := model newEntity: BBRoad from: aPlot to: itsNeighbour.
road stopped: 10. ""5""
road cross: 10. ""4.75: half cross, and 5 % of them are killed""
```

### Implementation Points

On an edge with several features, boars meet a highway first, then a road, then a river. The original model met them in an order that depended on hashing.
"
Class {
	#name : 'BBLinearFeature',
	#superclass : 'CMLink',
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBLinearFeature class >> crossingOrder [
	"Answer when boars meet me on an edge with several features: lower numbers first"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
BBLinearFeature class >> forLetter: aCharacter [

	^ self subclasses detect: [ :each | each letter = aCharacter ]
]

{ #category : 'accessing' }
BBLinearFeature class >> letter [
	"Answer the letter that stands for me in the edge codes of the plot table"

	^ self subclassResponsibility
]

{ #category : 'crossing' }
BBLinearFeature >> cross: aNumber [
	"Answer how many of aNumber boars reach the other side of me alive"

	^ aNumber * self permeability
]

{ #category : 'crossing' }
BBLinearFeature >> isDirected [

	^ false
]

{ #category : 'crossing' }
BBLinearFeature >> permeability [
	"Answer the share of the boars that cross me rather than turn back"

	^ self subclassResponsibility
]

{ #category : 'crossing' }
BBLinearFeature >> stopped: aNumber [
	"Answer how many of aNumber boars turn back at me"

	^ aNumber * (1 - self permeability)
]
