'use strict';

const { configs } = require('@nullvoxpopuli/eslint-configs');
const path = require('path');

let config = configs.node();

module.exports = {
    ...config,
    parser: '@babel/eslint-parser',
    parserOptions: {
        ...config.parserOptions,
        babelOptions: {
            configFile: path.resolve(__dirname, 'babel.config.cjs')
        }
    }
}