'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function (defaults) {
  let app = new EmberApp(defaults, {
    autoImport: {
      watchDependencies: ['ember-headless-form'],
      webpack: {
        externals: {
          // ember-sinon-qunit still depends on ember-sinon (until https://github.com/elwayman02/ember-sinon-qunit/pull/727 is merged and released), which provided sinon as an AMD shim
          // so no need for eai to pull it in additionally
          sinon: 'sinon',
        },
      },
    },
  });

  const { maybeEmbroider } = require('@embroider/test-setup');

  return maybeEmbroider(app);
};
