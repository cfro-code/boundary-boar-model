"
I am a hunting unit, the territory of a local hunting group, named by its number in the plot table, or 'NA'. My `huntingGroup` hunts on me, and I record the `bags` of the driven hunts on my plots for the last ten years. See `BBTerritory`.
"
Class {
	#name : 'BBHuntingUnit',
	#superclass : 'BBTerritory',
	#instVars : [
		'huntingGroup',
		'bags'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'accessing' }
BBHuntingUnit >> bags [
	"Answer the numbers of boars killed by driven hunts on my plots in the last years, at most ten, the latest last"

	^ bags
]

{ #category : 'accessing' }
BBHuntingUnit >> huntingGroup [
	"Answer the local hunting group that hunts on me"

	^ huntingGroup
]

{ #category : 'accessing' }
BBHuntingUnit >> huntingGroup: aHuntingGroup [

	huntingGroup := aHuntingGroup
]

{ #category : 'initialization' }
BBHuntingUnit >> initialize [

	super initialize.
	bags := OrderedCollection new
]

{ #category : 'hunting' }
BBHuntingUnit >> recordBag [

	bags add: (self components sum: [ :plot |
				 (plot occupantsOfClass: BBDrivenHunt)
					 inject: 0
					 into: [ :sum :each | sum + each boarsKilled ] ]).
	bags size > 10 ifTrue: [ bags removeFirst ]
]
