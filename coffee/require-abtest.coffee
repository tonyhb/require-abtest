define (require) ->

  # This stores which variation we show for each test for the current user.
  # It is defined locally so it can only be accessed via API calls
  userCohorts = {}

  # A list of test names, which contain a list of variations to visitor
  # percentages
  tests = {}

  # Require 'module' to load config options for the test plugin
  module = require 'module'
  # Get the test config options. This can either be a filename or an object of
  # tests; if it's a filename we load the file via RequireJS.
  config = module.config()
  if typeof config.tests is "object"
    tests = config.tests
  else if typeof config.tests is "string"
    # Require in the test file
    tests = require config.tests

  abtest =
    version: '0.1'
    runningTests: tests,

    cohorts: ->
      # @TODO: Clone this so that this can't be modified
      return userCohorts

    cohort: (testName) ->
      return @cohorts()[testName]

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
      # @TODO: Clear the user's cookie

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
      # @TODO: Track the cohort in a cookie
      userCohorts[testName] = variation

    # Persistence
    # ===========

    # Load the user's cohort via a cookie

    # Track the user's cohort via a cookie

    # RequireJS API
    # =============

    # Return a filename from a variation for a specific test
    # If the user is in a cohort already use their previous file, otherwise
    # randomly select a new file from all variations and assign the user to that
    # cohort.
    getFile: (testName) ->
      return @cohort(testName) if @cohort(testName)
      # Get all files and randomly choose one
      return @assignCohort(testName)
      throw new Error "Unable to assign  a variation for the test: " + testName

    load: (name, req, onload, config) ->
      # @TODO: Check to see if the user is in a cohort

      file = @getFile(name)

      suffixed = file
      req [suffixed], (value) ->
        onload(value)

  return abtest
