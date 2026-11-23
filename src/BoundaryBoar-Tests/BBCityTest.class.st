"
I check neighbourhood associations, how satisfied residents are with the boars in their town, and the policies cities choose when residents are not: less waste, less feeding or brush-cutting.
"
Class {
	#name : 'BBCityTest',
	#superclass : 'BBTestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'helpers' }
BBCityTest >> leafyTownWithBoars: aNumber [
	"Trees 0.2 and grass 0.15 make K = 20 * 0.2 * 0.4 * 1.5 * 1.15 = 2.76"

	^ self
		  townWithCover: {
				  ('treeCity' -> '0,2').
				  ('grassCity' -> '0,15') }
		  boars: aNumber
]

{ #category : 'tests' }
BBCityTest >> testAssociationsLiveWhereTownsWereDenseIn2018 [
	"Residents of Montpellier Méditerranée Métropole like boars more than elsewhere"

	| model |
	model := self
		         modelWithPlotRows: {
				         (self
					          plotRowAt: 1 @ 1
					          with: { ('administrativeTerritory' -> 'MMM') }).
				         (self
					          plotRowAt: 1 @ 2
					          with: { ('administrativeTerritory' -> 'CALunel') }).
				         (self plotRowAt: 1 @ 3 with: #(  )) }
		         coverRows: {
				         (self
					          coverRowAt: 1 @ 1
					          with: { ('coverCity_18' -> '0,4') }).
				         (self
					          coverRowAt: 1 @ 2
					          with: { ('coverCity_18' -> '0,4') }).
				         (self
					          coverRowAt: 1 @ 3
					          with: { ('coverCity_18' -> '0,2') }) }.

	self assert: (model cellAt: 1 at: 1) associations size equals: 1.
	self
		assert:
		(model cellAt: 1 at: 1) associations first preferredSaturation
		closeTo: 0.29.
	self
		assert:
		(model cellAt: 1 at: 2) associations first preferredSaturation
		closeTo: 0.15.
	self assert: (model cellAt: 1 at: 3) associations isEmpty
]

{ #category : 'tests' }
BBCityTest >> testCityBrushcutsWhenItCanNoLongerCutFood [
	"Brush-cutting turns some urban trees into grass on the plots where vegetation helps boars most"

	| plot |
	plot := self
		        townWithCover: {
				        ('treeCity' -> '0,4').
				        ('grassCity' -> '0,3') }
		        boars: 10.
	4 timesRepeat: [
			plot city
				raiseWastePolicy;
				raiseFeedingPolicy ].
	plot cormasModel applyCityPolicies.

	self assert: plot city brushcuttingCampaigns equals: 1.
	self assert: plot landCover urbanTrees closeTo: 0.35.
	self assert: plot landCover urbanGrass closeTo: 0.35.
	self assert: plot wasteAccessibility equals: 0
]

{ #category : 'tests' }
BBCityTest >> testDissatisfiedResidentsMakeTheirCityCutWasteFirst [
	"With waste as accessible as can be, cutting waste a quarter reduces the boars expected next year more than cutting feeding"

	| plot |
	plot := self leafyTownWithBoars: 10.
	plot cormasModel applyCityPolicies.

	self assert: plot city wastePolicy equals: 0.25.
	self assert: plot city feedingPolicy equals: 0.
	self assert: plot wasteAccessibility closeTo: 0.75
]

{ #category : 'tests' }
BBCityTest >> testResidentsAreDissatisfiedWhenBoarsAreTooMany [

	| association |
	association := (self leafyTownWithBoars: 2.76) associations first.

	self assert: association satisfaction closeTo: 1 - 0.71.
	self assert: association isDissatisfied
]

{ #category : 'tests' }
BBCityTest >> testResidentsAreSatisfiedWhenBoarsAreAsManyAsTheyWish [

	| association |
	association := (self leafyTownWithBoars: 2.76 * 0.29) associations
		               first.

	self assert: association perceivedSaturation closeTo: 0.29.
	self assert: association satisfaction closeTo: 1.
	self deny: association isDissatisfied
]

{ #category : 'tests' }
BBCityTest >> testSatisfiedResidentsLeaveTheirCityAsItIs [

	| plot |
	plot := self leafyTownWithBoars: 2.76 * 0.29.
	plot cormasModel applyCityPolicies.

	self assert: plot city wastePolicy equals: 0.
	self assert: plot city feedingPolicy equals: 0.
	self assert: plot wasteAccessibility closeTo: 1
]

{ #category : 'tests' }
BBCityTest >> testTerritoriesSumTheBoarsAndAverageTheResidentsOfTheirTowns [

	| model towns territory associations |
	model := self
		         modelWithPlotRows:
			         ({ 'GRABELS'. 'JUVIGNAC' } withIndexCollect: [ :town :column |
					          self plotRowAt: 1 @ column with: {
							          ('cityTerritory' -> town).
							          ('humanPopDensity' -> 'urbanDense').
							          ('livingStandard' -> 'veryLow').
							          ('administrativeTerritory' -> 'MMM') } ])
		         coverRows: ((1 to: 2) collect: [ :column |
					          self coverRowAt: 1 @ column with: {
							          ('coverCity_90' -> '0,5').
							          ('coverForest_90' -> '0,5').
							          ('coverCity_18' -> '0,5').
							          ('coverForest_18' -> '0,5').
							          ('treeCity' -> '0,2').
							          ('grassCity' -> '0,15') } ]).
	(model cellAt: 1 at: 1) boars: 2.
	(model cellAt: 1 at: 2) boars: 8.
	model assessSatisfaction.
	towns := model cells collect: [ :each | each cityTerritory ].
	territory := (model cellAt: 1 at: 1) administrativeTerritory.
	associations := model allEntitiesOfClass: BBAssociation.

	self assert: (towns allSatisfy: [ :each | each urbanBoars > 0 ]).
	self
		assert: (towns sum: [ :each | each urbanBoars ])
		closeTo: model urbanBoars.
	self assert: territory boars closeTo: 10.
	self assert: associations size equals: 2.
	self
		assert: territory meanSatisfaction
		closeTo: (associations sum: [ :each | each satisfaction ]) / 2
]

{ #category : 'helpers' }
BBCityTest >> townWithCover: someCoverAssociations boars: aNumber [
	"A dense, very poor town plot of Montpellier Méditerranée Métropole, all city since 1990, with the given urban vegetation"

	| model plot |
	model := self
		         modelWithPlotRows: { (self plotRowAt: 1 @ 1 with: {
					          ('humanPopDensity' -> 'urbanDense').
					          ('livingStandard' -> 'veryLow').
					          ('administrativeTerritory' -> 'MMM') }) }
		         coverRows: { (self coverRowAt: 1 @ 1 with: {
					          ('coverCity_90' -> '1').
					          ('coverCity_18' -> '1') } , someCoverAssociations) }.
	plot := model cellAt: 1 at: 1.
	plot boars: aNumber.
	model assessSatisfaction.
	^ plot
]
