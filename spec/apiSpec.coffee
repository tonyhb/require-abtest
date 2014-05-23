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
      test.test(newTestSettings)

      runningTests = test.tests()
      expect(runningTests['new test']).toBeDefined()
      expect(runningTests['new test']).toEqual
        description: 'an optional description for a manually created A/B test'
        variations:
          'variation a': 60
          'variation b': 40

    it "throws an error if you create a test with an existing name", ->
      expect( -> test.test(newTestSettings))
        .toThrow new Error("Test 'new test' already exists")

    it "throws an error if you create a test without a name", ->
      expect( -> test.test({variations: {}}))
        .toThrow new Error("Tests must have a name defined")

    it "throws an error if you create a test without variations", ->
      expect( -> test.test({name: 'Test'}))
        .toThrow(new Error("Tests must have at least two variations defined"))

    it "throws an error if you create a test with one variation", ->
      expect( -> test.test({
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

  describe "cohort", ->
    it "must throw an error with an incorrect test name", ->
    it "must assign a cohort to users without variations", ->
    it "must return a string when a user is in a cohort", ->
