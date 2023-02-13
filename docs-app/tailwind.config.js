'use strict';

const path = require('path');
const { tailwindConfig } = require('@crowdstrike/ember-oss-docs/tailwind');

const config = tailwindConfig(__dirname, {
  content: [path.join(__dirname, '../docs/**/*.md')],
});

module.exports = config;
