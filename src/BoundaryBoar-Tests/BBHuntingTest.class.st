"
I check driven hunts: how many boars they kill and scare away, how local hunting groups place more of them each year where boars are most numerous, and where hunting is not allowed.
"
Class {
	#name : 'BBHuntingTest',
	#superclass : 'BBTestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'helpers' }
BBHuntingTest >> groupOf: aModel [

	^ (aModel cellAt: 1 at: 1) huntingUnit huntingGroup
]

{ #category : 'helpers' }
BBHuntingTest >> huntedColumnsOf: aModel [

	^ (aModel cells select: [ :each |
		   (each occupantsOfClass: BBDrivenHunt) notEmpty ]) collect: [
		  :each | each columnNumber ]
]

{ #category : 'helpers' }
BBHuntingTest >> modelWithForestPlotsIn: someCityNames [
	"One row of pure forest plots of one hunting unit, the nth in the city of the nth name. The nth plot has n boars"

	| model |
	model := self
		         modelWithPlotRows:
			         ((1 to: someCityNames size) collect: [ :column |
					          self
						          plotRowAt: 1 @ column
						          with:
						          { ('cityTerritory' -> (someCityNames at: column)) } ])
		         coverRows:
			         ((1 to: someCityNames size) collect: [ :column |
				          self
					          coverRowAt: 1 @ column
					          with: { ('coverForest_90' -> '1') } ]).
	model cells do: [ :each | each boars: each columnNumber ].
	^ model
]

{ #category : 'tests' }
BBHuntingTest >> testDrivenHuntKillsATenthOfTheBoarsOfItsPlot [

	| model plot hunt |
	model := self modelWithForestPlotsIn:
		         #( 'GRABELS' 'GRABELS' 'GRABELS' ).
	plot := model cellAt: 1 at: 2.
	plot boars: 100.
	hunt := (self groupOf: model) organizeHuntOn: plot.
	model huntBoars.

	self assert: plot boars closeTo: 90.
	self assert: hunt boarsKilled closeTo: 10.
	self assert: plot huntingUnit bags last closeTo: 10
]

{ #category : 'tests' }
BBHuntingTest >> testHuntedBoarsFleeToNeighbours [
	"A driven hunt scares away 30 % of the boars of its plot"

	| model plot |
	model := self modelWithForestPlotsIn:
		         #( 'GRABELS' 'GRABELS' 'GRABELS' ).
	(model cellAt: 1 at: 1) boars: 0.
	plot := model cellAt: 1 at: 2.
	plot boars: 10.
	(model cellAt: 1 at: 3) boars: 0.
	(self groupOf: model) organizeHuntOn: plot.
	model disperseBoarsByHunting.

	self assert: plot boars closeTo: 7.
	self assert: (model cellAt: 1 at: 1) boars closeTo: 1.5.
	self assert: (model cellAt: 1 at: 3) boars closeTo: 1.5
]

{ #category : 'tests' }
BBHuntingTest >> testHuntingGroupsDoNotHuntInTowns [

	| model town |
	model := self modelWithForestPlotsIn:
		         (Array new: 10 withAll: 'GRABELS').
	town := model cellAt: 1 at: 10.
	town landCover changeBy: (BBLandCover types collect: [ :each |
				 each -> ({
					  (#Forest -> -0.5).
					  (#City -> 0.5) } asDictionary at: each ifAbsent: [ 0 ]) ])
			asDictionary.
	(self groupOf: model) organizeHuntsIn: 2018.

	self deny: town isHuntable.
	self deny: ((self huntedColumnsOf: model) includes: 10).
	self assert: (self huntedColumnsOf: model) size equals: 8
]

{ #category : 'tests' }
BBHuntingTest >> testHuntingGroupsHuntMorePlotsEachYearUntil2018 [
	"From 2.5 % of the huntable plots in 1990 to 90 % in 2018, on the plots with the most boars"

	| model |
	model := self modelWithForestPlotsIn:
		         (Array new: 10 withAll: 'GRABELS').
	(self groupOf: model) organizeHuntsIn: 2004.

	self
		assert: (self huntedColumnsOf: model) asSet
		equals: (6 to: 10) asSet.

	(self groupOf: model) organizeHuntsIn: 2018.

	self assert: (self huntedColumnsOf: model) size equals: 9
]

{ #category : 'tests' }
BBHuntingTest >> testHuntingStaysAllowedIn2018WhereThereIsNoMontpellier [

	| model |
	model := self modelWithForestPlotsIn: #( 'NIMES' 'GRABELS' ).
	model applyScenariosIn: 2018.

	self assert: (model cellAt: 1 at: 1) isHuntable.
	self assert: (model cellAt: 1 at: 2) isHuntable
]

{ #category : 'tests' }
BBHuntingTest >> testHuntsLeaveTheCitiesThatBanHunting [

	| model |
	model := self modelWithForestPlotsIn:
		         #( 'MONTPELLIER' 'MONTPELLIER' 'MONTPELLIER' 'MONTPELLIER'
		            'MONTPELLIER' 'GRABELS' 'GRABELS' 'GRABELS' 'GRABELS'
		            'GRABELS' ).
	(self groupOf: model) organizeHuntsIn: 2018.
	(model cellAt: 1 at: 1) city banHunting.
	(self groupOf: model) organizeHuntsIn: 2019.

	self
		assert: (self huntedColumnsOf: model) asSet
		equals: (6 to: 10) asSet
]

{ #category : 'tests' }
BBHuntingTest >> testLeastEfficientHuntMovesToThePlotWithTheMostBoars [

	| model weakest |
	model := self modelWithForestPlotsIn:
		         (Array new: 10 withAll: 'GRABELS').
	(self groupOf: model) organizeHuntsIn: 2004.
	(self groupOf: model) hunts do: [ :each | each boarsKilled: 5 ].
	weakest := ((model cellAt: 1 at: 6) occupantsOfClass: BBDrivenHunt)
		           first.
	weakest boarsKilled: 0.
	(model cellAt: 1 at: 1) boars: 100.
	(self groupOf: model) organizeHuntsIn: 2005.

	self
		assert: (self huntedColumnsOf: model) asSet
		equals: { 1. 7. 8. 9. 10 } asSet.
	self assert: weakest cell identicalTo: (model cellAt: 1 at: 1)
]

{ #category : 'tests' }
BBHuntingTest >> testMontpellierBansHuntingIn2018 [

	| model |
	model := self modelWithForestPlotsIn: #( 'MONTPELLIER' 'GRABELS' ).
	model applyScenariosIn: 2017.

	self assert: (model cellAt: 1 at: 1) isHuntable.

	model applyScenariosIn: 2018.

	self deny: (model cellAt: 1 at: 1) isHuntable.
	self assert: (model cellAt: 1 at: 2) isHuntable
]

{ #category : 'tests' }
BBHuntingTest >> testTwoHuntsOnAPlotEachKillATenthOfTheBoarsBeforeTheHunts [

	| model plot |
	model := self modelWithForestPlotsIn:
		         #( 'GRABELS' 'GRABELS' 'GRABELS' ).
	plot := model cellAt: 1 at: 2.
	plot boars: 100.
	2 timesRepeat: [ (self groupOf: model) organizeHuntOn: plot ].
	model huntBoars.

	self assert: plot boars closeTo: 80.
	self assert: plot huntingUnit bags last closeTo: 20
]
