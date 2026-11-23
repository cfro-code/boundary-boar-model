"
I am a territory made of plots that share a name in the plot table: a municipality, an administrative territory or a hunting unit. My plots need not touch each other.

## Responsibility:

- Know my name.
- Know my plots, as any Cormas aggregate.
- Measure the boars of my plots, the satisfaction of the residents and the damage of the farmers who live there.
- Leave to my subclasses what each kind of territory does.

## Collaborators:

- `BBModel` creates me with all the plots of a name.
- `BBPlot` answers the territories it belongs to.

## Public API and Key Messages

- `name` answers my name, such as 'MONTPELLIER', 'MMM' or '8'.
- `components` answers my plots.
- My probes `boars`, `meanSatisfaction` and `meanFarmerDamage` are recorded for each territory, and my charts show them when I am inspected.
- I am not drawn by default, so that the land cover of my plots shows clearly; my aspect Border draws my border.

```
(model cellAt: 9 at: 12) cityTerritory name. ""'MONTPELLIER'""
```

## Internal Representation

- `name` is the text of the plot table that my plots share.
"
Class {
	#name : 'BBTerritory',
	#superclass : 'CMSpatialEntityAggregate',
	#instVars : [
		'name'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'aspects' }
BBTerritory >> aspectBorder: look [
	"The border Cormas draws around an aggregate"

	<aspect>
	super aspectDefault: look
]

{ #category : 'aspects' }
BBTerritory >> aspectDefault: look [
	"Territories are not drawn by default: their plots show them with their own aspects, such as Municipality"

	<aspect>
	look beInvisible
]

{ #category : 'probes' }
BBTerritory >> boars [

	<probe>
	^ self components sum: [ :each | each boars ]
]

{ #category : 'charts' }
BBTerritory >> chartBoars [
	"How many boars live on my plots?"

	<chart>
	^ CMChart new
		  title: 'Boars';
		  lineX: #currentTimeStep y: #boars;
		  hideLegend;
		  yourself
]

{ #category : 'charts' }
BBTerritory >> chartResidentsAndFarmers [
	"Are my residents satisfied with the boars around them, and how much do my farmers lose?"

	<chart>
	^ CMChart new
		  title: 'Residents and farmers';
		  add: (CMLineSeries new
				   x: #currentTimeStep y: #meanSatisfaction;
				   label: 'Mean satisfaction of residents';
				   yourself);
		  add: (CMLineSeries new
				   x: #currentTimeStep y: #meanFarmerDamage;
				   label: 'Mean farmer damage';
				   yourself);
		  yFrom: 0 to: 1;
		  yourself
]

{ #category : 'probes' }
BBTerritory >> meanFarmerDamage [
	"Answer the mean damage of the farmers on my plots, or 0 when there are none"

	<probe>
	| farmers |
	farmers := self components flatCollect: [ :each | each farmers ].
	farmers isEmpty ifTrue: [ ^ 0 ].
	^ (farmers sum: [ :each | each damage ]) / farmers size
]

{ #category : 'probes' }
BBTerritory >> meanSatisfaction [
	"Answer the mean satisfaction of the residents' associations on my plots, or 0 when there are none"

	<probe>
	| associations |
	associations := self components flatCollect: [ :each |
		                each associations ].
	associations isEmpty ifTrue: [ ^ 0 ].
	^ (associations sum: [ :each | each satisfaction ])
	  / associations size
]

{ #category : 'accessing' }
BBTerritory >> name [

	^ name
]

{ #category : 'accessing' }
BBTerritory >> name: aString [

	name := aString
]

{ #category : 'printing' }
BBTerritory >> printOn: aStream [

	aStream nextPutAll: name
]
