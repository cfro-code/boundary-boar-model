"
I am a territory made of plots that share a name in the plot table: a municipality, an administrative territory or a hunting unit. My plots need not touch each other.

## Responsibility:

- Know my name.
- Know my plots, as any Cormas aggregate.
- Leave to my subclasses what each kind of territory does.

## Collaborators:

- `BBModel` creates me with all the plots of a name.
- `BBPlot` answers the territories it belongs to.

## Public API and Key Messages

- `name` answers my name, such as 'MONTPELLIER', 'MMM' or '8'.
- `components` answers my plots.

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

{ #category : 'accessing' }
BBTerritory >> name [

	^ name
]

{ #category : 'accessing' }
BBTerritory >> name: aString [

	name := aString
]
