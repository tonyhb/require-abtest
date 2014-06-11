define ['test'], (test) ->

  describe "the cookie helper", -> 

    test.createTest
      name: "cookie test"
      variations:
        a: 50
        b: 50

    it "must get and set the user's cohorts", ->
      test.reset()
      expect(test.cookie.get()).toEqual {}

      test.cohort('cookie test')
      cookie = test.cookie.get()
      expect(cookie['cookie test']).toBeDefined()
