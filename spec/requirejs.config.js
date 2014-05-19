// Run through all included JS files to find specs.
var tests, i;
tests = ['spec/data/ab-tests'];
for (i in window.__karma__.files) {
  if (window.__karma__.files.hasOwnProperty(i) && i.indexOf("Spec") > 0) {
    tests.push(i);
  }
}

require.config({
  deps: tests,
  baseUrl: '/base/',
  callback: window.__karma__.start,
  paths: {
    test: 'js/require-abtest'
  },
  config: {
    test: {
      settings: {
        tracking: 'spec/data/tracking'
      },
      tests: 'spec/data/ab-tests'
    }
  }
});
