define ['test', 'spec/data/ab-tests'], (test, abtests) ->

  describe "tests", ->
    it "returns an object of tests", ->
      runningTests = test.tests()
      expect(runningTests).toEqual abtests

  describe "test", ->
    newTestSettings =
      name: 'new test'
      description: 'an optional description for a manually created A/B test'
      variations:
        'variation a': 60
        'variation b': 40

    it "creates a new test manually", ->
      test.createTest(newTestSettings)

      runningTests = test.tests()
      expect(runningTests['new test']).toBeDefined()
      expect(runningTests['new test']).toEqual newTestSettings

    it "throws an error if you create a test with an existing name", ->
      expect( -> test.createTest(newTestSettings))
        .toThrow new Error("Test 'new test' already exists")

    it "throws an error if you create a test without a name", ->
      expect( -> test.createTest({variations: {}}))
        .toThrow new Error("Tests must have a name defined")

    it "throws an error if you create a test without variations", ->
      expect( -> test.createTest({name: 'Test'}))
        .toThrow(new Error("Tests must have at least two variations defined"))

    it "throws an error if you create a test with one variation", ->
      expect( -> test.createTest({
        name: 'Test'
        variations:
          'variation a': 100
      }))
        .toThrow(new Error("Tests must have at least two variations defined"))

  describe "variations", ->
    it "must return variations for a specific test", ->
      variations = test.variations('spec/data/page')
      expect(variations.constructor).toBe Object
      expect(variations).toEqual abtests['spec/data/page'].variations

  describe "cohorts", ->
    it "must return an empty object when a user is in no cohort", ->
      test.reset()
      expect(test.cohorts()).toEqual {}

    it "must return an object when a user is in a cohort", ->
      test.persist 'new test', 'variation a'
      expect(test.cohorts()).toEqual
        'new test': 'variation a'

  describe "cohort", ->
    it "must throw an error with an incorrect test name", ->
      expect( -> test.cohort('foo'))
        .toThrow new Error("Test 'foo' is undefined")

    it "must assign a cohort to users without variations", ->
      test.reset()
      variation = test.cohort('new test')
      expect(variation).toBeDefined()
      expect(variation.constructor).toBe String
      expect(test.cohorts()['new test']).toBeDefined

    it "must return a string when a user is in a cohort", ->
      expect(test.cohort('new test')).toEqual test.cohorts()['new test']
