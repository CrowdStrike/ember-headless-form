'use strict';

const path = require('path');

const monorepoRoot = path.resolve(__dirname, '..');

module.exports = {
  repository: {
    url: 'https://github.com/CrowdStrike/ember-headless-form',
    editBranch: 'main',
  },
  sources: [
    {
      root: path.resolve(monorepoRoot, 'docs'),
      pattern: '**/*.md',
      // if set to "manual", the URL will need to be specified in each markdown file
      urlSchema: 'auto',
      urlPrefix: 'docs',
    },
  ],
};
