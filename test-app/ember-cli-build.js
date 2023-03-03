'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function (defaults) {
  let app = new EmberApp(defaults, {
    autoImport: {
      watchDependencies: [
        'ember-headless-form',
        '@ember-headless-form/changeset',
      ],
      // See https://github.com/ef4/ember-auto-import/issues/564#issuecomment-1448820349
      earlyBootSet: () => ['@glimmer/tracking'],
    },
  });

  const { maybeEmbroider } = require('@embroider/test-setup');

  return maybeEmbroider(app);
};
