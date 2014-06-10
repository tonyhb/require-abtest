define(function(require) {
  var COOKIE_KEY, abtest, config, module, tests, userCohorts;
  COOKIE_KEY = 'rjs-ab';
  userCohorts = {};
  tests = {};
  abtest = {
    version: '0.1',
    runningTests: tests,
    cohorts: function() {
      return userCohorts;
    },
    cohort: function(testName) {
      if (this.tests()[testName] === void 0) {
        throw new Error("Test '" + testName + "' is undefined");
      }
      if (userCohorts[testName] !== void 0) {
        return userCohorts[testName];
      }
      return this.assignCohort(testName);
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
      userCohorts = {};
      return this.cookie.set();
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
      userCohorts[testName] = variation;
      return this.cookie.set();
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
    },
    cookie: {
      get: function() {
        var cohorts, cookieFragment, _i, _len, _ref;
        _ref = document.cookie.split(';');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cookieFragment = _ref[_i];
          cookieFragment.replace(/^\s+/, '');
          if (cookieFragment.indexOf(COOKIE_KEY) !== 0) {
            continue;
          }
          cohorts = cookieFragment.substring(COOKIE_KEY.length + 1);
          return JSON.parse(decodeURIComponent(cohorts));
        }
      },
      set: function() {
        var date, expires, value;
        date = new Date;
        date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toGMTString();
        value = encodeURIComponent(JSON.stringify(userCohorts));
        return document.cookie = COOKIE_KEY + "=" + value + expires + "; path=/";
      }
    }
  };
  module = require('module');
  config = module.config();
  if (typeof config.tests === "object") {
    tests = config.tests;
  } else if (typeof config.tests === "string") {
    tests = require(config.tests);
  }
  userCohorts = abtest.cookie.get() || {};
  return abtest;
});
