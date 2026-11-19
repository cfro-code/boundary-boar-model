"
I am a corner of the hexagonal plots, where roads, highways and rivers start and end, so that they are drawn along the borders between plots rather than between their centers. I stand on a plot, at one of its six corners, and I am shared by every feature that touches my corner.

## Responsibility:

- Stand at a corner of a plot, as the end of the features on the edges that meet there.
- Be shared by the plots around my corner: there is only one of me at each corner.
- Stay invisible, since I only hold the lines.

## Collaborators:

- `BBModel` creates me when it creates the first feature that touches my corner.
- `BBLinearFeature`: roads, highways and rivers are links between two of us.

## Public API and Key Messages

I have no behaviour of my own. A feature answers its corners with `ends`:

```
road ends. ""the two BBNode at the ends of its edge""
```

### Implementation Points

My corner is my `positionInCell` on the plot that created me. The corners are numbered as in the original model: 1 bottom left, 2 left, 3 top left, 4 top right, 5 right and 6 bottom right.
"
Class {
	#name : 'BBNode',
	#superclass : 'CMAgent',
	#category : 'BoundaryBoar-Model',
	#package : 'BoundaryBoar-Model'
}

{ #category : 'aspects' }
BBNode >> aspectDefault: look [
	"Only the features between nodes are drawn"

	<aspect>
	look beInvisible
]
