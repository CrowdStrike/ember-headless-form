'use strict';

module.exports = {
  plugins: ['prettier-plugin-ember-template-tag'],
  singleQuote: true,
  templateSingleQuote: false,
  overrides: [
    {
      files: '*.gjs',
      options: {
        parser: 'ember-template-tag',
      },
    },
    {
      files: '*.gts',
      options: {
        parser: 'ember-template-tag',
      },
    },
  ],
};
