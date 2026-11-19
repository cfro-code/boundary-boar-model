Class {
	#name : 'BaselineOfBoundaryBoar',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBoundaryBoar',
	#package : 'BaselineOfBoundaryBoar'
}

{ #category : 'baselines' }
BaselineOfBoundaryBoar >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			package: 'BoundaryBoar-Model';
			package: 'BoundaryBoar-Tests' with: [ spec requires: #( 'BoundaryBoar-Model' ) ] ]
]

{ #category : 'baselines' }
BaselineOfBoundaryBoar >> isManagedByCormas [
	"Cormas wrote this baseline and keeps it up to date when packages of the model are added, renamed or removed. If you change the baseline yourself, Cormas asks whether you want to manage it yourself: this method then returns false, and Cormas never changes the baseline again"

	^ true
]
