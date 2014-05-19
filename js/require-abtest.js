define(function(require) {
  var abtest, config, module;
  abtest = {
    version: '0.1',
    tests: tests,
    load: function(name, req, onload, config) {
      var file, suffixed;
      file = this.getFileNameFromPercentile(this.tests[name]);
      suffixed = name + '.' + file;
      return req([suffixed], function(value) {
        return onload(value);
      });
    },
    getPercentile: function() {
      return Math.floor(Math.random() * 99);
    },
    getFileNameFromPercentile: function(files) {
      var currentPercentile, name, percentile, split;
      percentile = this.getPercentile();
      currentPercentile = 0;
      for (name in files) {
        split = files[name];
        currentPercentile += split;
        if (percentile < currentPercentile) {
          return name;
        }
      }
      for (name in files) {
        return name;
      }
    }
  };
  module = require('module');
  config = module.config();
  if (typeof config.tests === "object") {
    abtest.tests = config.tests;
  } else if (typeof config.tests === "string") {
    abtest.tests = require(config.tests);
  } else {
    throw new Error("tests config option must be an object or a filename");
  }
  return abtest;
});
