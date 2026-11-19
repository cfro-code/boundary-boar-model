"
I am an inter-municipal body, such as Montpellier Méditerranée Métropole, which can ban hunting in all my cities, or have them follow each other's waste and feeding policies. By default I do neither: both are scenarios, as in the original model.

## Responsibility:

- Ban hunting in my cities when I ban it.
- Keep my cities within one quarter of the most advanced waste and feeding policies when I coordinate them.

## Collaborators:

- `BBAdministrativeTerritory`: my territory, whose plots belong to my cities.
- `BBCity`: my cities.

## Public API and Key Messages

- `banHunting` and `coordinatePolicies` turn the scenarios on; `applyPolicies` applies them every year from 2019.
- `cities` answers my cities.
"
Class {
	#name : 'BBAdministrativeEntity',
	#superclass : 'CMAgent',
	#instVars : [
		'territory',
		'isHuntingAllowed',
		'coordinatesPolicies'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'policies' }
BBAdministrativeEntity >> applyPolicies [

	isHuntingAllowed ifFalse: [
		self cities do: [ :each | each banHunting ] ].
	coordinatesPolicies ifTrue: [
			| cities |
			cities := self cities.
			cities do: [ :each |
					each
						raiseWastePolicyTo:
							(cities detectMax: [ :city | city wastePolicy ]) wastePolicy
							- 0.25;
						raiseFeedingPolicyTo:
							(cities detectMax: [ :city | city feedingPolicy ])
								feedingPolicy - 0.25 ] ]
]

{ #category : 'policies' }
BBAdministrativeEntity >> banHunting [
	"Forbid hunting in all my cities, for good"

	isHuntingAllowed := false
]

{ #category : 'accessing' }
BBAdministrativeEntity >> cities [

	^ (territory components collect: [ :each | each city ]) asIdentitySet
]

{ #category : 'policies' }
BBAdministrativeEntity >> coordinatePolicies [
	"Have my cities follow each other's waste and feeding policies: none may lag more than one quarter behind the most advanced"

	coordinatesPolicies := true
]

{ #category : 'initialization' }
BBAdministrativeEntity >> initialize [

	super initialize.
	isHuntingAllowed := true.
	coordinatesPolicies := false
]

{ #category : 'accessing' }
BBAdministrativeEntity >> territory [

	^ territory
]

{ #category : 'initialization' }
BBAdministrativeEntity >> territory: anAdministrativeTerritory [

	territory := anAdministrativeTerritory
]
