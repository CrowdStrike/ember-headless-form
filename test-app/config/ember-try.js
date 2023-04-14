'use strict';

const getChannelURL = require('ember-source-channel-url');
const { embroiderSafe, embroiderOptimized } = require('@embroider/test-setup');

module.exports = async function () {
  let releaseVersion = await getChannelURL('release');

  return {
    usePnpm: true,
    scenarios: [
      {
        name: 'ember-lts-4.4',
        npm: {
          devDependencies: {
            'ember-source': '~4.4.0',
          },
        },
      },
      {
        name: 'ember-lts-4.8',
        npm: {
          devDependencies: {
            'ember-source': '~4.8.0',
          },
        },
      },
      {
        name: 'ember-release',
        npm: {
          devDependencies: {
            'ember-source': releaseVersion,
          },
        },
      },
      {
        name: 'ember-beta',
        npm: {
          devDependencies: {
            'ember-source': await getChannelURL('beta'),
          },
        },
      },
      {
        name: 'ember-canary',
        npm: {
          devDependencies: {
            'ember-source': await getChannelURL('canary'),
          },
        },
      },
      embroiderSafe({
        name: 'ember-lts-4.8 + embroider-safe',
        npm: {
          devDependencies: {
            'ember-source': '~4.8.0',
            // @todo remove this once we have a stable release that includes https://github.com/embroider-build/embroider/pull/1383
            '@embroider/core': '2.1.2-unstable.3a9d8ad',
            '@embroider/compat': '2.1.2-unstable.3a9d8ad',
            '@embroider/webpack': '2.1.2-unstable.3a9d8ad',
          },
        },
      }),
      embroiderOptimized({
        name: 'ember-lts-4.8 + embroider-optimized',
        npm: {
          devDependencies: {
            'ember-source': '~4.8.0',
            // @todo remove this once we have a stable release that includes https://github.com/embroider-build/embroider/pull/1383
            '@embroider/core': '2.1.2-unstable.3a9d8ad',
            '@embroider/compat': '2.1.2-unstable.3a9d8ad',
            '@embroider/webpack': '2.1.2-unstable.3a9d8ad',
          },
        },
      }),
      embroiderOptimized({
        name: 'ember-release + embroider-optimized',
        npm: {
          devDependencies: {
            'ember-source': releaseVersion,
            // @todo remove this once we have a stable release that includes https://github.com/embroider-build/embroider/pull/1383
            '@embroider/core': '2.1.2-unstable.3a9d8ad',
            '@embroider/compat': '2.1.2-unstable.3a9d8ad',
            '@embroider/webpack': '2.1.2-unstable.3a9d8ad',
          },
        },
      }),
    ],
  };
};
