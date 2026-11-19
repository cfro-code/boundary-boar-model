"
I am the hunting federation of the department. Every year from 2019, I give temporary fences to the farmers who ask, the most damaged first, as long as my budget lasts.

## Responsibility:

- Know my budget of fences: those the State pays for, a parameter of my class, and one for every two plots the local hunting groups can hunt.
- Give temporary fences to the farmers who ask.

## Collaborators:

- `BBFarmer` asks me for fences.
- `BBHuntingGroup` tells how many plots it can hunt.

## Public API and Key Messages

- `fenceBudget` and `grantTemporaryFencesTo: someFarmers`.

```
model huntingFederation fenceBudget. ""40 plus half the huntable plots""
```

### Implementation Points

The hunting groups count their huntable plots when I ask. The original counted them a little earlier, at the previous year's hunts.
"
Class {
	#name : 'BBHuntingFederation',
	#superclass : 'CMAgent',
	#classInstVars : [
		'stateFenceBudget'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'parameters' }
BBHuntingFederation class >> stateFenceBudget [
	"The number of temporary fences the State pays for each year"

	<parameterIntegerMin: 0 max: 1000 default: 40>
	^ stateFenceBudget
]

{ #category : 'parameters' }
BBHuntingFederation class >> stateFenceBudget: anInteger [

	stateFenceBudget := anInteger
]

{ #category : 'fences' }
BBHuntingFederation >> fenceBudget [
	"Answer the number of temporary fences I can give this year: those the State pays for, and one for every two plots the local hunting groups can hunt"

	^ self class stateFenceBudget
	  + ((self cormasModel allEntitiesOfClass: BBHuntingGroup)
			   inject: 0
			   into: [ :sum :each | sum + each huntingCapacity ]) / 2
]

{ #category : 'fences' }
BBHuntingFederation >> grantTemporaryFencesTo: someFarmers [
	"Give temporary fences to the farmers who asked, the most damaged first, as long as my budget lasts"

	| budget |
	budget := self fenceBudget.
	(someFarmers sorted: [ :a :b | a damage >= b damage ]) do: [ :each |
			budget <= 0 ifTrue: [ ^ self ].
			each installTemporaryFences.
			budget := budget - 1 ]
]
