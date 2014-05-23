define ['test', 'test!spec/data/page'], (test, page) ->

  describe "cohort splitting", ->
    it "must split a user into a cohort randomly", ->
      testName = 'spec/data/page'
      # Record the number of times these variations are chosen from `getFile`
      files = {
        'spec/data/page-a': 0
        'spec/data/page-b': 0
      }

      for i in [0..1000]
        t = test.assignCohort(testName)
        files[t]++
      # This test will fail eventually. Not sure what we can do about it
      # though. How do you test randomness?
      expect(files['spec/data/page-a'] > 400).toBeTruthy()
      expect(files['spec/data/page-b'] > 400).toBeTruthy()

    it "must return all cohorts the user is currently in", ->
      cohorts = test.cohorts()
      expect(cohorts.constructor).toBe Object
      expect(cohorts['spec/data/page']).toBeDefined()


  describe "cookie persistence", ->

    it "must store the user's cohorts in a cookie", ->

    it "must load a user's cohorts from a cookie", ->

    it "must return the correct file when a user's cohort is cookied", ->
