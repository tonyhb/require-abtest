define ['module'], (module) ->

  abtest =
    version: '0.1'

    load: (name, req, onload, config) ->
      version = @getVersionNameFromPercentile(config.abtest[name])
      suffixed = name + '.' + version
      req [suffixed], (value) ->
        onload(value)

    getPercentile: ->
      Math.floor(Math.random() * 99)

    getVersionNameFromPercentile: (versions) ->
      percentile = @getPercentile()

      currentPercentile = 0

      for name, split of versions
        currentPercentile += split
        return name if percentile < currentPercentile

      # Default to the first item
      return name for name of versions


  return abtest

