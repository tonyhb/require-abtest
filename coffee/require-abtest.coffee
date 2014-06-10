define ['tests', 'require'], (tests, require) ->

  COOKIE_KEY = 'rjs-ab'

  # This stores which variation we show for each test for the current user.
  # It is defined locally so it can only be accessed via API calls
  userCohorts = {}

  # A list of test names, which contain a list of variations to visitor
  # percentages
  tests = tests || {}

  # During optimization document isn't defined and r.js throws an error... even
  # if we don't use document.cookie for cohort setting. Fix that issue.
  document = document || {
    cookie: ''
  }

  # Stores a list of all tests and their variations to their module definitions
  # for r.js optimisation. This is only used for opimisation, enabling us to
  # write definitions properly in `write()`
  #
  # buildMap = {
  #   'test name': {
  #     'a': module
  #     'b': module
  #   }
  # }
  buildMap = {}

  abtest =
    version: '0.1'
    runningTests: tests,

    cohorts: ->
      # @TODO: Clone this so that this can't be modified
      return userCohorts

    # Get the cohort the user is in for the current test. If the user is not in
    # a cohort, assign one and return the variation name.
    cohort: (testName) ->
      # Fail hard if the test doesn't exist
      if @tests()[testName] is undefined
        throw new Error("Test '" + testName + "' is undefined")

      return userCohorts[testName] if userCohorts[testName] isnt undefined
      # If the user has no cohort assign one
      return @assignCohort(testName)

    tests: ->
      # @TODO: Clone this so that this can't be modified
      return tests

    variations: (testName) ->
      test = tests[testName]
      return test.variations if test

    description: (testName) ->
      test = tests[testName]
      return test.description if test

    reset: ->
      userCohorts = {}
      @cookie.set()

    # Create a new test
    # =================

    test: (settings) ->
      throw new Error("Tests must have a name defined") unless settings.name

      if tests[settings.name] isnt undefined
        throw new Error("Test '" + settings.name + "' already exists")

      count = 0
      count++ for i of settings.variations if settings.variations
      if ! settings.variations || count < 2
        throw new Error("Tests must have at least two variations defined")

      tests[settings.name] =
        description: settings.description
        variations: settings.variations

    # Cohort splitting
    # ================

    # Get a random number between 0 and 99; this is used when assigning the
    # current visitor to a new cohort.
    getPercentile: ->
      Math.floor(Math.random() * 99)

    # Choose a variation from a list of options to their split percentages.
    # Doing the following:
    #   assignCohort({a: 25, b: 25, c: 50})
    # will return 'a' 25% of the time, 'b' 25% of the time and 'c' 50% of the
    # time.
    #
    # Note that this will overwrite the user's current variation for this test.
    assignCohort: (testName) ->
      percentile = @getPercentile()
      currentPercentile = 0

      variations = @variations(testName)
      for variation, split of variations
        currentPercentile += split

        if percentile < currentPercentile
          @persist(testName, variation)
          return variation

    persist: (testName, variation) ->
      userCohorts[testName] = variation
      @cookie.set()

    # RequireJS API
    # =============

    # Return a filename from a variation for a specific testl
    # If the user is in a cohort already use their previous file, otherwise
    # randomly select a new file from all variations and assign the user to that
    # cohort.
    getFile: (testName) ->
      return @cohort(testName) if @cohort(testName)
      # Get all files and randomly choose one
      return @assignCohort(testName)
      throw new Error "Unable to assign  a variation for the test: " + testName

    load: (name, req, onload, config) ->
      @loadAll.apply @, arguments if config.isBuild

      file = @getFile(name)
      req [file], (module) ->
        onload(module)

    # Optimisation
    # ============

    # Load all variations for optimisation
    loadAll: (testName, req, onload, config) ->
      variations = @variations(testName)

      for variation, split of variations
        require [variation], (module) =>
          @finishLoad testName, variation, module, onload, config

    finishLoad: (testName, variation, module, onload, config) ->
      buildMap[testName] = buildMap[testName] || {}
      buildMap[testName][variation] = module
      onload(module)

    # Used by the r.js optimiser to write definitions to the optimised file.
    write: (pluginName, moduleName, write, config) ->
      return unless buildMap.hasOwnProperty(moduleName)

      variationDefinitions = buildMap[moduleName]
      for module, variation of variationDefinitions
        write.asModule(variation, module)


    # Cookie manipulation
    # ===================

    cookie:
      get: ->
        for cookieFragment in document.cookie.split ';'
          # Remove leading slashes
          cookieFragment.replace /^\s+/, ''
          continue if cookieFragment.indexOf(COOKIE_KEY) isnt 0

          cohorts = cookieFragment.substring COOKIE_KEY.length + 1
          return JSON.parse decodeURIComponent cohorts

      set: ->
        return {} unless document
        date = new Date
        date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000))
        expires = "; expires=" + date.toGMTString()

        value = encodeURIComponent JSON.stringify(userCohorts)
        document.cookie = COOKIE_KEY + "=" + value + expires + "; path=/"

  # Get all user cohorts after defining abtest
  userCohorts = abtest.cookie.get() || {}

  return abtest
