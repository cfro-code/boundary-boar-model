"
I am a municipality, which manages a city territory. For now I only decide whether hunting is allowed on my territory; my policies against boars come later.

## Responsibility:

- Manage my `BBCityTerritory`.
- Allow or ban hunting on my territory.

## Collaborators:

- `BBCityTerritory`: my territory, which knows me.
- `BBPlot` asks me whether hunting is allowed on it.

## Public API and Key Messages

- `name` answers the name of my territory, such as 'MONTPELLIER'.
- `isHuntingAllowed` and `banHunting`.

```
(model cellAt: 9 at: 12) city banHunting.
```
"
Class {
	#name : 'BBCity',
	#superclass : 'CMAgent',
	#instVars : [
		'territory',
		'isHuntingAllowed'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'hunting' }
BBCity >> banHunting [
	"Forbid hunting on my territory, for good"

	isHuntingAllowed := false
]

{ #category : 'initialization' }
BBCity >> initialize [

	super initialize.
	isHuntingAllowed := true
]

{ #category : 'accessing' }
BBCity >> isHuntingAllowed [

	^ isHuntingAllowed
]

{ #category : 'accessing' }
BBCity >> name [

	^ territory name
]

{ #category : 'accessing' }
BBCity >> territory [

	^ territory
]

{ #category : 'accessing' }
BBCity >> territory: aCityTerritory [

	territory := aCityTerritory
]
