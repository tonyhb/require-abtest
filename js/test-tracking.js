define(function() {
  var Tracking;
  return Tracking = {
    track: function(name, variation, index, test) {
      if (window.ga === void 0) {
        return;
      }
      if (test.experimentId) {
        this.trackViaExperiments.apply(this, arguments);
      }
      return ga('send', 'event', 'a/b tests', name, variation, {
        nonInteraction: 1
      });
    },
    trackViaExperiments: function(name, variation, index, test) {
      window.ga('set', 'expId', test.experimentId);
      window.ga('set', 'expVar', index);
      if (window.cxApi) {
        return cxApi.setChosenVariation(index, test.experimentId);
      }
    }
  };
});
