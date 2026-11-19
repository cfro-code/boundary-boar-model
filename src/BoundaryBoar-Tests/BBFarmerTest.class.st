"
I check farmers: how they share the farmland of their plot, the damage boars do to their crops, and how they protect them with fences from the hunting federation, permanent fences and stands.
"
Class {
	#name : 'BBFarmerTest',
	#superclass : 'BBTestCase',
	#category : 'BoundaryBoar-Tests',
	#package : 'BoundaryBoar-Tests'
}

{ #category : 'helpers' }
BBFarmerTest >> expectedDamageWith: aNumberOfBoars [
	"On pure farmland with acorns at 0.5, K = 20 * 0.4 * 1.1 and the habitat potential is 0.9 * 1.25. Boars eat less in farmland in a good acorn year, by 1 - (0.7 * 0.5 squared)"

	^ aNumberOfBoars * (1 - (0.7 * 0.25))
	  / (20 * 0.4 * 1.1 * (0.4 * 1.1) / (0.9 * 1.25)) min: 1
]

{ #category : 'helpers' }
BBFarmerTest >> modelWithFarmPlotsOf: aCrop boars: someNumbers [

	^ self modelWithFarmPlotsOf: aCrop boars: someNumbers parameters: [ ]
]

{ #category : 'helpers' }
BBFarmerTest >> modelWithFarmPlotsOf: aCrop boars: someNumbers parameters: aBlock [
	"A row of plots covered with farmland of one crop, the nth with the nth number of boars. aBlock sets parameters, after the model gives them their defaults and before it creates its entities"

	| model |
	model := BBModel new.
	aBlock value.
	model
		initWithPlotTable: ((1 to: someNumbers size) collect: [ :column |
				 self plotRowAt: 1 @ column with: #(  ) ])
		coverTable: ((1 to: someNumbers size) collect: [ :column |
					 self coverRowAt: 1 @ column with: {
							 ('coverAgri_90' -> '1').
							 (aCrop -> '1') } ]).
	model cells
		with: someNumbers
		do: [ :plot :boars | plot boars: boars ].
	^ model
]

{ #category : 'tests' }
BBFarmerTest >> testDamageGrowsWithTheBoarsOnFarmland [

	| model |
	model := self modelWithFarmPlotsOf: 'wine' boars: #( 0 2 ).
	model assessDamage.

	self assert: (model cellAt: 1 at: 1) farmers first damage equals: 0.
	self
		assert: (model cellAt: 1 at: 2) farmers first damage
		closeTo: (self expectedDamageWith: 2)
]

{ #category : 'tests' }
BBFarmerTest >> testFarmersBuildPermanentFencesAfterYearsOfHeavyDamage [
	"Every farmer who gets no temporary fence installs permanent ones after three years of full damage"

	| model farmers |
	model := self
		         modelWithFarmPlotsOf: 'vegetable'
		         boars: #( 6 )
		         parameters: [
				         BBHuntingFederation stateFenceBudget: 0.
				         BBVegetableFarmer fencingProbability: 1 ].
	farmers := (model cellAt: 1 at: 1) farmers.
	3 timesRepeat: [ model assessDamage ].
	model protectCrops.

	self assert: (farmers allSatisfy: [ :each | each damage = 1 ]).
	self
		assert: (farmers count: [ :each | each hasTemporaryFences not ])
		equals: 2.
	self assert:
		((farmers reject: [ :each | each hasTemporaryFences ]) allSatisfy: [
			 :each | each hasPermanentFences ])
]

{ #category : 'tests' }
BBFarmerTest >> testFarmersShareTheFarmlandOfTheirPlot [
	"60 % of farmland makes 1 + 1 = 2 farmers' worth: one wine grower for 70 % of it, one grain farmer for 30 %, and no vegetable farmer for 3 %"

	| model farmers |
	model := self
		         modelWithPlotRows: { (self plotRowAt: 1 @ 1 with: #(  )) }
		         coverRows: { (self coverRowAt: 1 @ 1 with: {
					          ('coverAgri_90' -> '0,6').
					          ('wine' -> '0,7').
					          ('grain' -> '0,3').
					          ('vegetable' -> '0,03') }) }.
	farmers := (model cellAt: 1 at: 1) farmers.

	self
		assert: (farmers collect: [ :each | each class ]) asBag
		equals: {
				BBWineGrower.
				BBGrainFarmer } asBag.
	self
		assert:
		(farmers detect: [ :each | each class = BBWineGrower ]) surface
		closeTo: 0.42.
	self
		assert:
		(farmers detect: [ :each | each class = BBGrainFarmer ]) surface
		closeTo: 0.18
]

{ #category : 'tests' }
BBFarmerTest >> testFarmersUnderHeavyPressureHuntOnTheirPlot [
	"A farmer without permanent fences sets up a stand when boars are above 70 % of what the farmland can hold"

	| model |
	model := self modelWithFarmPlotsOf: 'grain' boars: #( 1 4 ).
	model assessDamage.
	model protectCrops.

	self assert:
		((model cellAt: 1 at: 1) occupantsOfClass: BBStand) isEmpty.
	self
		assert: ((model cellAt: 1 at: 2) occupantsOfClass: BBStand) size
		equals: 3.
	self
		assert:
			((model cellAt: 1 at: 2) occupantsOfClass: BBStand) first organizer
				class
		equals: BBGrainFarmer
]

{ #category : 'tests' }
BBFarmerTest >> testFederationGivesItsFencesToTheMostDamagedFarmersFirst [
	"Both plots have three wine growers, damaged above 50 %. The State pays for no fence, and the hunters for one, half a fence for each plot they can hunt"

	| model |
	model := self
		         modelWithFarmPlotsOf: 'wine'
		         boars: #( 3 4 )
		         parameters: [ BBHuntingFederation stateFenceBudget: 0 ].
	model assessDamage.
	model protectCrops.

	self assert: model huntingFederation fenceBudget equals: 1.
	self
		assert: ((model cellAt: 1 at: 2) farmers count: [ :each |
				 each hasTemporaryFences ])
		equals: 1.
	self deny: ((model cellAt: 1 at: 1) farmers anySatisfy: [ :each |
			 each hasTemporaryFences ])
]

{ #category : 'tests' }
BBFarmerTest >> testFencesProtectCrops [

	| model temporary permanent |
	model := self modelWithFarmPlotsOf: 'wine' boars: #( 2 2 ).
	temporary := (model cellAt: 1 at: 1) farmers first.
	temporary installTemporaryFences.
	permanent := (model cellAt: 1 at: 2) farmers first.
	permanent installPermanentFences.
	model assessDamage.

	self
		assert: temporary damage
		closeTo: (self expectedDamageWith: 2) * 0.7.
	self
		assert: permanent damage
		closeTo: (self expectedDamageWith: 2) * 0.1
]

{ #category : 'tests' }
BBFarmerTest >> testStandKillsSomeOfTheBoarsNearTheCropsOfItsFarmer [
	"A stand kills 40 % of the boars in the farmland of its farmer, in proportion to the farmer's surface"

	| model plot farmer stand |
	model := self modelWithFarmPlotsOf: 'grain' boars: #( 4 ).
	plot := model cellAt: 1 at: 1.
	farmer := plot farmers first.
	stand := farmer setUpStand.
	model huntBoars.

	self assert: stand boarsKilled closeTo: 4 * (1 / 3) * 0.4.
	self assert: plot boars closeTo: 4 - (4 * (1 / 3) * 0.4)
]
