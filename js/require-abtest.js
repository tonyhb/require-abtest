define(['module'], function(module) {
  var abtest;
  abtest = {
    version: '0.1',
    load: function(name, req, onload, config) {
      var suffixed, version;
      version = this.getVersionNameFromPercentile(config.abtest[name]);
      suffixed = name + '.' + version;
      return req([suffixed], function(value) {
        return onload(value);
      });
    },
    getPercentile: function() {
      return Math.floor(Math.random() * 99);
    },
    getVersionNameFromPercentile: function(versions) {
      var currentPercentile, name, percentile, split;
      percentile = this.getPercentile();
      currentPercentile = 0;
      for (name in versions) {
        split = versions[name];
        currentPercentile += split;
        if (percentile < currentPercentile) {
          return name;
        }
      }
      for (name in versions) {
        return name;
      }
    }
  };
  return abtest;
});
