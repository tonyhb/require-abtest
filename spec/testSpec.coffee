define ['test', 'spec/data/ab-tests'], (test, abtests) ->

  describe "require-abtest", ->

    it "must load tests from an external file", ->
      expect(test.tests).toEqual abtests

