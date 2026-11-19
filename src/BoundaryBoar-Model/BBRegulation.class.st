"
I am an action against boars on one plot: a driven hunt, a stand or a trap. I kill a share of the boars of my plot, my lethality, and scare away another share, my dispersion pressure.

## Responsibility:

- Stand on the plot where I take place.
- Kill my share of the boars of my plot, and remember how many.
- Know who organized me.

## Collaborators:

- `BBPlot`: my plot loses the boars I kill, and the boars I scare away leave it.
- My organizer, a `BBHuntingGroup`, a `BBFarmer` or the `BBDDTM`, tells whether I last from year to year.
- `BBModel` asks me to hunt every year.

## Public API and Key Messages

- `hunt` computes the boars I kill, from the boars of my plot before anyone hunts. `BBModel>>huntBoars` then removes them from the plot.
- `boarsKilled`, `lethality`, `dispersionPressure` and `organizer` answer what I am.
- `lastsOneYear` answers whether I am removed at the start of next year: only the hunts of hunting groups stay.

```
hunt := aHuntingGroup organizeHuntOn: aPlot.
hunt hunt.
hunt boarsKilled. ""a tenth of the boars of aPlot""
```

## Internal Representation

- `organizer` is the agent that organized me.
- `boarsKilled` is the number of boars I killed in the last hunt, 0 before.

### Implementation Points

My subclasses give their lethality and dispersion pressure as parameters of their class.
"
Class {
	#name : 'BBRegulation',
	#superclass : 'CMAgent',
	#instVars : [
		'organizer',
		'boarsKilled'
	],
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'aspects' }
BBRegulation >> aspectOrganizer: look [
	"My default look, in one color for each kind of organizer: hunting groups, farmers and the State services"

	<aspect>
	self aspectDefault: look.
	look colorGroupedBy: ((organizer isKindOf: BBFarmer)
			 ifTrue: [ BBFarmer ]
			 ifFalse: [ organizer class ])
]

{ #category : 'accessing' }
BBRegulation >> boarsKilled [
	"Answer the number of boars I killed in the last hunt"

	^ boarsKilled
]

{ #category : 'accessing' }
BBRegulation >> boarsKilled: aNumber [

	boarsKilled := aNumber
]

{ #category : 'accessing' }
BBRegulation >> dispersionPressure [
	"Answer the share of the boars of my plot that I scare away"

	^ self class dispersionPressure
]

{ #category : 'hunting' }
BBRegulation >> hunt [
	"Kill my share of the boars of my plot. My plot loses them once every regulation of my kind has hunted"

	boarsKilled := self cell boars * self lethality
]

{ #category : 'initialization' }
BBRegulation >> initialize [

	super initialize.
	boarsKilled := 0
]

{ #category : 'hunting' }
BBRegulation >> lastsOneYear [

	^ organizer keepsItsRegulations not
]

{ #category : 'accessing' }
BBRegulation >> lethality [
	"Answer the share of the boars of my plot that I kill"

	^ self class lethality
]

{ #category : 'accessing' }
BBRegulation >> organizer [
	"Answer who organized me, such as a hunting group"

	^ organizer
]

{ #category : 'accessing' }
BBRegulation >> organizer: anAgent [

	organizer := anAgent
]
