define (require) ->

  abtest =
    version: '0.1'
    tests: tests,

    load: (name, req, onload, config) ->
      file = @getFileNameFromPercentile(@tests[name])
      suffixed = name + '.' + file
      req [suffixed], (value) ->
        onload(value)

    # Cohort splitting
    # ================

    # Get a random number between 0 and 99; this is used when assigning the
    # current visitor to a new cohort.
    getPercentile: ->
      Math.floor(Math.random() * 99)

    # Randomly select a file to load from a list of potential files
    getFileNameFromPercentile: (files) ->
      percentile = @getPercentile()
      currentPercentile = 0

      for name, split of files
        currentPercentile += split
        return name if percentile < currentPercentile

      # Default to the first item
      return name for name of files



  # Require 'module' to load config options for the test plugin
  module = require 'module'

  # Get the test config options. This can either be a filename or an object of
  # tests; if it's a filename we load the file via RequireJS.
  config = module.config()
  if typeof config.tests is "object"
    abtest.tests = config.tests
  else if typeof config.tests is "string"
    # Require in the test file
    abtest.tests = require config.tests
  else
    throw new Error "tests config option must be an object or a filename"

  return abtest
