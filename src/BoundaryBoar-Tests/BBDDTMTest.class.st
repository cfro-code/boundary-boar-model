"
I check the interventions of the State services (DDTM): who asks for them, which means they use on which plots, how many they can make each year, and how long they last.
"
Class {
	#name : 'BBDDTMTest',
	#superclass : 'BBTestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'helpers' }
BBDDTMTest >> plotWithCity: aCityFraction [

	^ (self
		   modelWithPlotRows: { (self plotRowAt: 1 @ 1 with: #(  )) }
		   coverRows: { (self coverRowAt: 1 @ 1 with: {
					    ('coverCity_90' -> aCityFraction printString).
					    ('coverForest_90' -> (1 - aCityFraction) printString).
					    ('treeCity' -> '0,2') }) }) cellAt: 1 at: 1
]

{ #category : 'helpers' }
BBDDTMTest >> regulationColumnsOf: aModel [

	^ (aModel cells select: [ :each | each regulations notEmpty ])
		  collect: [ :each | each columnNumber ]
]

{ #category : 'tests' }
BBDDTMTest >> testDDTMChoosesItsMeansFromTheLandscape [
	"A driven hunt where hunters can hunt, a trap in dense town, a stand in between"

	| countryside suburb town |
	countryside := self plotWithCity: 0.
	suburb := self plotWithCity: 0.6.
	town := self plotWithCity: 0.9.

	self
		assert:
		(countryside cormasModel ddtm interveneOn: countryside) class
		equals: BBDrivenHunt.
	self
		assert: (suburb cormasModel ddtm interveneOn: suburb) class
		equals: BBStand.
	self
		assert: (town cormasModel ddtm interveneOn: town) class
		equals: BBTrapping
]

{ #category : 'tests' }
BBDDTMTest >> testDDTMHelpsTheMostOverrunTownsFirstFiveTimesAYear [

	| model |
	model := self townsOverrunBy: #( 0.91 0.97 0.92 0.96 0.93 0.95 0.94 ).
	model requestInterventions.
	model ddtm intervene.

	self
		assert: (self regulationColumnsOf: model) asSet
		equals: #( 2 4 5 6 7 ) asSet
]

{ #category : 'tests' }
BBDDTMTest >> testDDTMStandsShootAmongAllTheBoarsOfTheirPlot [

	| suburb |
	suburb := self plotWithCity: 0.6.
	suburb boars: 10.
	suburb cormasModel ddtm interveneOn: suburb.
	suburb cormasModel huntBoars.

	self assert: suburb boars closeTo: 6
]

{ #category : 'tests' }
BBDDTMTest >> testDDTMTrapsBoarsInTownsTheyOverrun [
	"Cities ask for an intervention where boars fill more than 90 % of what a town can hold. In dense town, the DDTM traps them"

	| model |
	model := self townsOverrunBy: #( 1 0.8 ).
	model requestInterventions.
	model ddtm intervene.

	self
		assert:
			((model cellAt: 1 at: 1) regulations collect: [ :each | each class ])
				asArray
		equals: { BBTrapping }.
	self
		assert: (model cellAt: 1 at: 1) regulations first organizer
		identicalTo: model ddtm.
	self
		assert: (model ddtm interventionsOn: (model cellAt: 1 at: 1))
		equals: 1.
	self assert: (model cellAt: 1 at: 2) regulations isEmpty
]

{ #category : 'tests' }
BBDDTMTest >> testFarmersWhoMayNotHuntAskTheDDTM [

	| model plot |
	model := self
		         modelWithPlotRows: { (self plotRowAt: 1 @ 1 with: #(  )) }
		         coverRows: { (self coverRowAt: 1 @ 1 with: {
					          ('coverAgri_90' -> '1').
					          ('grain' -> '1') }) }.
	plot := model cellAt: 1 at: 1.
	plot boars: 4.
	plot farmers do: [ :each | each forbidStands ].
	model assessDamage.
	model protectCrops.
	model ddtm intervene.

	self assert: (plot occupantsOfClass: BBStand) isEmpty.
	self assert: (plot occupantsOfClass: BBDrivenHunt) size equals: 3.
	self
		assert: (plot occupantsOfClass: BBDrivenHunt) first organizer
		identicalTo: model ddtm
]

{ #category : 'tests' }
BBDDTMTest >> testInterventionsLastOneYearButHuntingGroupsKeepTheirHunts [

	| countryside model |
	countryside := self plotWithCity: 0.
	model := countryside cormasModel.
	model ddtm interveneOn: countryside.
	countryside huntingUnit huntingGroup organizeHuntOn: countryside.
	model removeOneYearRegulations.

	self assert: countryside regulations size equals: 1.
	self
		assert: countryside regulations first organizer
		identicalTo: countryside huntingUnit huntingGroup
]

{ #category : 'tests' }
BBDDTMTest >> testTrapsKillMostBoarsOfTheirPlot [

	| town |
	town := self plotWithCity: 0.9.
	town boars: 10.
	town cormasModel ddtm interveneOn: town.
	town cormasModel huntBoars.

	self assert: town boars closeTo: 3
]

{ #category : 'helpers' }
BBDDTMTest >> townsOverrunBy: someSaturations [
	"A row of dense town plots of Montpellier Méditerranée Métropole, each with an association, where trees 0.2 and grass 0.15 make K = 2.76, and the nth town is as full of boars as the nth saturation"

	| model |
	model := self
		         modelWithPlotRows:
			         ((1 to: someSaturations size) collect: [ :column |
					          self plotRowAt: 1 @ column with: {
							          ('humanPopDensity' -> 'urbanDense').
							          ('livingStandard' -> 'veryLow') } ])
		         coverRows:
			         ((1 to: someSaturations size) collect: [ :column |
					          self coverRowAt: 1 @ column with: {
							          ('coverCity_90' -> '1').
							          ('coverCity_18' -> '1').
							          ('treeCity' -> '0,2').
							          ('grassCity' -> '0,15') } ]).
	model cells
		with: someSaturations
		do: [ :plot :saturation | plot boars: 2.76 * saturation ].
	model assessSatisfaction.
	^ model
]
