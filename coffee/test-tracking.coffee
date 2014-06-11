define ->

  Tracking =
    track: (name, variation, index, test) ->
      return if window.ga is undefined

      # Use Google Experiments if possible
      if test.experimentId
        @trackViaExperiments.apply(@, arguments)

      # Track via a Google Analytics non-interactive event
      ga 'send', 'event', 'a/b tests', name, variation, {
        nonInteraction: 1
      }

    trackViaExperiments: (name, variation, index, test) ->
      # Track via ga.js
      window.ga 'set', 'expId', test.experimentId
      window.ga 'set', 'expVar', index

      # Also use the Google Experiments API if possible
      cxApi.setChosenVariation(index, test.experimentId) if window.cxApi

      # We need to send a non-interaction event to make sure GA tracks this;
      # this is handled in our original track() method
