'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');

const isProduction = () => EmberApp.env() === 'production';

module.exports = function (defaults) {
  let app = new EmberApp(defaults, {
    autoImport: {
      watchDependencies: ['ember-headless-form'],
    },
    'ember-cli-babel': {
      enableTypeScriptTransform: true,
    },
  });

  // Use `app.import` to add additional libraries to the generated
  // output files.
  //
  // If you need to use different assets in different
  // environments, specify an object as the first parameter. That
  // object's keys should be the environment name and the values
  // should be the asset to use in that environment.
  //
  // If the library that you are including contains AMD or ES6
  // modules that you would like to import into your application
  // please specify an object with the list of modules as keys
  // along with the exports of each module as its value.

  const { Webpack } = require('@embroider/webpack');

  return require('@embroider/compat').compatBuild(app, Webpack, {
    extraPublicTrees: [],
    staticAddonTestSupportTrees: true,
    staticAddonTrees: true,
    staticModifiers: true,
    /**
     * Docfy does not allow us to use staticComponents
     */
    staticComponents: false,
    staticHelpers: false,

    splitAtRoutes: ['/', '/docs'],
    skipBabel: [
      {
        package: 'qunit',
      },
    ],
    /**
     * Modern CSS config from: https://discuss.emberjs.com/t/ember-modern-css/19614
     * - lazy loaded CSS
     * - CSS Modules
     */
    packagerOptions: {
      publicAssetURL: '/',
      cssLoaderOptions: {
        sourceMap: isProduction() === false,
        // Native CSS Modules
        modules: {
          // global mode, can be either global or local
          // we set to global mode to avoid hashing tailwind classes
          mode: 'global',
          // class naming template
          localIdentName: isProduction()
            ? '[sha512:hash:base64:5]'
            : '[path][name]__[local]',
        },
      },
      webpackConfig: {
        // devServer: {
        //   static: './dist',
        //   hot: true,
        // },
        module: {
          rules: [
            {
              // When webpack sees an import for a CSS files
              test: /\.css$/i,
              // exclude: /node_modules/,
              use: [
                {
                  loader: 'postcss-loader',
                  options: {
                    sourceMap: isProduction() === false,
                    postcssOptions: {
                      config: './postcss.config.js',
                    },
                  },
                },
              ],
            },
            {
              test: /\.(png|svg|jpg|jpeg|gif|webp)$/i,
              type: 'asset/resource',
            },
          ],
        },
      },
    },
  });
};
