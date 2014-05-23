define(function(require) {
  var abtest, config, module, tests, userCohorts;
  userCohorts = {};
  tests = {};
  module = require('module');
  config = module.config();
  if (typeof config.tests === "object") {
    tests = config.tests;
  } else if (typeof config.tests === "string") {
    tests = require(config.tests);
  }
  abtest = {
    version: '0.1',
    runningTests: tests,
    cohorts: function() {
      return userCohorts;
    },
    cohort: function(testName) {
      return this.cohorts()[testName];
    },
    tests: function() {
      return tests;
    },
    variations: function(testName) {
      var test;
      test = tests[testName];
      if (test) {
        return test.variations;
      }
    },
    description: function(testName) {
      var test;
      test = tests[testName];
      if (test) {
        return test.description;
      }
    },
    reset: function() {
      return userCohorts = {};
    },
    test: function(settings) {
      var count, i;
      if (!settings.name) {
        throw new Error("Tests must have a name defined");
      }
      if (tests[settings.name] !== void 0) {
        throw new Error("Test '" + settings.name + "' already exists");
      }
      count = 0;
      if (settings.variations) {
        for (i in settings.variations) {
          count++;
        }
      }
      if (!settings.variations || count < 2) {
        throw new Error("Tests must have at least two variations defined");
      }
      return tests[settings.name] = {
        description: settings.description,
        variations: settings.variations
      };
    },
    getPercentile: function() {
      return Math.floor(Math.random() * 99);
    },
    assignCohort: function(testName) {
      var currentPercentile, percentile, split, variation, variations;
      percentile = this.getPercentile();
      currentPercentile = 0;
      variations = this.variations(testName);
      for (variation in variations) {
        split = variations[variation];
        currentPercentile += split;
        if (percentile < currentPercentile) {
          this.persist(testName, variation);
          return variation;
        }
      }
    },
    persist: function(testName, variation) {
      return userCohorts[testName] = variation;
    },
    getFile: function(testName) {
      if (this.cohort(testName)) {
        return this.cohort(testName);
      }
      return this.assignCohort(testName);
      throw new Error("Unable to assign  a variation for the test: " + testName);
    },
    load: function(name, req, onload, config) {
      var file, suffixed;
      file = this.getFile(name);
      suffixed = file;
      return req([suffixed], function(value) {
        return onload(value);
      });
    }
  };
  return abtest;
});
