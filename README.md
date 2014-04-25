# RequireJS A/B Testing

Simple split testing for RequireJS.

Since A/B testing is swapping out one piece of functionality for another, it
makes sense to bundle this in with RequireJS. RequireJS manages dependencies 
for JS, so what's stopping it from returning multiple variations for a 
dependency?

## Plans

The current plan for configuring tests (and the RequireJS module itself) is
outlined in [this github
issue](https://github.com/tonyhb/require-abtest/issues/1). Until something is
built, the API is in flux and will be discussed and decided on there.
