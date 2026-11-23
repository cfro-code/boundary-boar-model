"
I am a hunting unit, the territory of a local hunting group, named by its number in the plot table, or 'NA'. My `huntingGroup` hunts on me, and I record the `bags` of the driven hunts on my plots for the last ten years. My probes measure my `bag` of the year, its `meanBag` over the last ten years, my `drivenHunts` and the `huntersSatisfaction` of my group. See `BBTerritory`.
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

{ #category : 'probes' }
BBHuntingUnit >> bag [
	"Answer the number of boars killed this year by the driven hunts on my plots"

	<probe>
	^ self components sum: [ :plot |
			  (plot occupantsOfClass: BBDrivenHunt)
				  inject: 0
				  into: [ :sum :each | sum + each boarsKilled ] ]
]

{ #category : 'accessing' }
BBHuntingUnit >> bags [
	"Answer the numbers of boars killed by driven hunts on my plots in the last years, at most ten, the latest last"

	^ bags
]

{ #category : 'charts' }
BBHuntingUnit >> chartBag [
	"Is this year's bag as good as those of the last ten years?"

	<chart>
	^ CMChart new
		  title: 'Bag';
		  add: (CMLineSeries new
				   x: #currentTimeStep y: #bag;
				   label: 'Bag of the year';
				   yourself);
		  add: (CMLineSeries new
				   x: #currentTimeStep y: #meanBag;
				   label: 'Mean bag of the last ten years';
				   yourself);
		  yTitle: 'Boars killed';
		  yourself
]

{ #category : 'charts' }
BBHuntingUnit >> chartHuntersSatisfaction [
	"How satisfied are my hunters with their hunts?"

	<chart>
	^ CMChart new
		  title: 'Satisfaction of hunters';
		  lineX: #currentTimeStep y: #huntersSatisfaction;
		  yFrom: 0 to: 1;
		  hideLegend;
		  yourself
]

{ #category : 'probes' }
BBHuntingUnit >> drivenHunts [
	"Answer the number of driven hunts on my plots"

	<probe>
	^ self components sum: [ :each |
		  (each occupantsOfClass: BBDrivenHunt) size ]
]

{ #category : 'probes' }
BBHuntingUnit >> huntersSatisfaction [

	<probe>
	^ huntingGroup satisfaction
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

{ #category : 'probes' }
BBHuntingUnit >> meanBag [
	"Answer the mean of my bags over the last ten years, or 0 before the first hunts"

	<probe>
	bags isEmpty ifTrue: [ ^ 0 ].
	^ (bags sum: [ :each | each ]) / bags size
]

{ #category : 'hunting' }
BBHuntingUnit >> recordBag [

	bags add: self bag.
	bags size > 10 ifTrue: [ bags removeFirst ]
]
