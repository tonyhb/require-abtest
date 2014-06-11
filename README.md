![rjs](http://requirejs.org/i/logo.png)

# RequireJS A/B Testing

Simple split testing for RequireJS.

Since A/B testing is swapping out one piece of functionality for another, it
makes sense to bundle this in with RequireJS. RequireJS manages dependencies 
for JS, so what's stopping it from returning multiple variations for a 
dependency?

## Quick start

### Config

require-abtest uses the following config options:

    require.config({
      deps: ['test-definitions', 'test-tracking'], // Plus your dependencies
      paths: {
        // Point the 'test' library to our requirejs library
        test: 'js/libs/require-abtest',

        // These two files list all A/B tests and tracking.
        'test-definitions': 'helpers/tests', // Optionally rename dependencies
        'test-tracking': 'helpers/tracking', // Optionally rename dependencies
      }
    });

The **test-definitions** file lists all A/B tests, and the **test-tracking**
file is used to report to google analytics/kissmetrics/whatever when you assign
a user to a variation. You can name them whatever you want via the `paths` or
`map` config options.

This is the config setup done.

### Test definitions and running tests

Tests are defined as follows:
    
    define(function() {
      return {
        'path/to/page/module': { // <-- This key is the 'test name'
          description: 'Page module test',
          variations: {
            'path/to/page/module-version-a': 50, // This version gets 50% of traffic
            'path/to/page/module-version-b': 25, // And this gets 25%
            'path/to/page/module-version-c': 25,
          },
          experimentId: 'google_analytics_experiment_id' // optional
        }
      };
    });

In order to run this test, you would require the page module as follows:

    // Just put "test!" before any of the test keys defined above
    define(['test!path/to/page/module'], (Page) {
      // Page will be one of the three defined variations
    });

Note some important things:

1. You require in the test name, prefixed with "test!"
2. The plugin automatically assigns the user to a cohort and injects one of the
   defined variations
3. This cookies the user so they always get this version
4. This fires tracking defined in `test-tracking` (see the next section)
5. You don't need to do anything else. Magic.

This is basically it. Define your tests, require them in and you're done.

### Tracking

The plugin automatically cookies users so they get the same variation every
time. You also need to track the variations in some platform like Google 
Analytics to know what the shit is going on.

Enter: tracking. See
`[coffee/test-tracking](https://github.com/tonyhb/require-abtest/blob/master/coffee/test-tracking.coffee)` for an example.

In short: The tracking module should define an object which implements the
`track` method as follows:

    define(function() {
      Tracking = {
        track: function(testName, variation, variationIndex, test) {
          // Do your tracking shit here
        }
      }
    });

What are these arguments?

- `testName`: The name of the test (eg `path/to/page/module`. Descriptive, eh?)
- `variation`: The name of the variation (eg `path/to/page/module-version-b`.
  Even better)
- `variationIndex`: The index of the variation (0, 1, 2 according to how they're
  defined. Needed for ga.js experiments)
- `test`: The test object, which will contian `test.description`,
  `test.experimentId` and whatever else you defined.

So, this should let you track whatever you need. The default implementation
integrates with Google Analytics and Google Analytics content experiments. 

To implement **GA Experiments**, follow [this handy Google guide which tells 
you to ignore most of Google's
interface.](https://developers.google.com/analytics/solutions/experiments-client-side).
Smart.


## Helping, bugs, and other stuff

Add ideas, comments and issues to our github issues tracker. Feel free to add
any improvements or work from tasks on there, and submit a PR when it's ready.

There's bound to be bugs, despite testing it. Please report them (and fix if you
can. The code isn't complex).
