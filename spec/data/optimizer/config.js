require.config({
  deps: ['tests', 'main'],
  paths: {
    test: '../../../js/require-abtest',
  },
  config: {
    test: {
      settings: {
        tracking: 'tracking'
      },
    }
  }
});
