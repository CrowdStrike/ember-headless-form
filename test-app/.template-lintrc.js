'use strict';

module.exports = {
  extends: 'recommended',
  rules: {
    // this seems to cause false positives with template imports in tests
    'no-implicit-this': 'off',
  },
};
