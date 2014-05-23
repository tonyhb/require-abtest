define ['test', 'spec/data/ab-tests'], (test, abtests) ->

  describe "RequireJS API", ->
    # @TODO: This depends on the RequireJS config that we already have written.
    #        We should remove this dependency so this is testable
    it "must load running test definitions from an external file", ->
      expect(test.tests()).toEqual abtests

    it "must return a variation's filename for a test", ->
      file = test.getFile('spec/data/page')
      expect(file.constructor).toBe String
