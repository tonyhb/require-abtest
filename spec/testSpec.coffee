define ['test', 'spec/data/ab-tests'], (test, abtests) ->

  describe "require-abtest", ->

    it "must load tests from an external file", ->
      expect(test.tests).toEqual abtests

    it "must split a user into a cohort randomly", ->
      files = {
        'spec/data/page-a': 0
        'spec/data/page-b': 0
      }

      for i in [0..1000]
        t = test.getFile('spec/data/page')
        files[t]++

      # This test will fail eventually. Not sure what we can do about it
      # though. How do you test randomness?
      expect(files['spec/data/page-a'] > 400).toBeTruthy()
      expect(files['spec/data/page-b'] > 400).toBeTruthy()

