# ember-headless-form

## 1.1.0

### Minor Changes

- [#442](https://github.com/CrowdStrike/ember-headless-form/pull/442) [`6a9cc44`](https://github.com/CrowdStrike/ember-headless-form/commit/6a9cc44fc35eeb8ba034a23226ea1c2d06130969) Thanks [@basz](https://github.com/basz)! - Adds checkbox-group similar to radio-group

## 1.0.1

### Patch Changes

- [#421](https://github.com/CrowdStrike/ember-headless-form/pull/421) [`ec33d19`](https://github.com/CrowdStrike/ember-headless-form/commit/ec33d19ee5edc81f344b12fb9a40385cedf3bb2d) Thanks [@simonihmig](https://github.com/simonihmig)! - Remove optional chaining in `assert()` call to workaround [upstream bug](https://github.com/ember-cli/babel-plugin-debug-macros/issues/89)

## 1.0.0

### Major Changes

- [#34](https://github.com/CrowdStrike/ember-headless-form/pull/34) [`ad9072b`](https://github.com/CrowdStrike/ember-headless-form/commit/ad9072bd02cb38a75a1d05efdfefb88dc827cade) Thanks [@NullVoxPopuli](https://github.com/NullVoxPopuli)! - Initial release

### Patch Changes

- [#80](https://github.com/CrowdStrike/ember-headless-form/pull/80) [`241ccdc`](https://github.com/CrowdStrike/ember-headless-form/commit/241ccdcedaf52d8af8b3f366b61d3055e9e38fc9) Thanks [@simonihmig](https://github.com/simonihmig)! - Add `@ignoreNativeValidation` for opting out of native validation

- [#136](https://github.com/CrowdStrike/ember-headless-form/pull/136) [`da9f16c`](https://github.com/CrowdStrike/ember-headless-form/commit/da9f16c5165c98c70f3f5caf0042aa162fb435bc) Thanks [@simonihmig](https://github.com/simonihmig)! - Yield `submit` and `reset` actions

  `<HeadlessForm>` yields `submit` and `reset` actions, that can be used in place of the native buttons.

- [#134](https://github.com/CrowdStrike/ember-headless-form/pull/134) [`a3908fc`](https://github.com/CrowdStrike/ember-headless-form/commit/a3908fcf51dc1caa955a355c3e8e2a23d2cc341c) Thanks [@simonihmig](https://github.com/simonihmig)! - Add support for reset button

  Click a native `reset` button will reset the state of the form.

- [#121](https://github.com/CrowdStrike/ember-headless-form/pull/121) [`fdc4ff9`](https://github.com/CrowdStrike/ember-headless-form/commit/fdc4ff9fd8a2ba00c1f2f1fe04ece8f83ffe97b3) Thanks [@simonihmig](https://github.com/simonihmig)! - Support numbers for Inputs with `@type="number"

  For `@type="number"` Inputs we support passing its value as a real number, and parse and return it as a number as well.

- [#77](https://github.com/CrowdStrike/ember-headless-form/pull/77) [`7c7ff9f`](https://github.com/CrowdStrike/ember-headless-form/commit/7c7ff9f47a24eeddd9ac8f9a4c2643eb5e500582) Thanks [@simonihmig](https://github.com/simonihmig)! - Yield `rawErrors` for custom error rendering

  Both the form and each field yield a `rawErrors` property that gives access to the raw validation error objects for custom error rendering.

- [#76](https://github.com/CrowdStrike/ember-headless-form/pull/76) [`544509b`](https://github.com/CrowdStrike/ember-headless-form/commit/544509b256fb171e62cc74b2cba2b2f32faa6f35) Thanks [@simonihmig](https://github.com/simonihmig)! - Refactor radio group for better a11y

- [#84](https://github.com/CrowdStrike/ember-headless-form/pull/84) [`67a5169`](https://github.com/CrowdStrike/ember-headless-form/commit/67a5169eb11552d7db9eb1f2553f59dfaad9aa65) Thanks [@simonihmig](https://github.com/simonihmig)! - Convert addon to use template tag

- [#147](https://github.com/CrowdStrike/ember-headless-form/pull/147) [`6984523`](https://github.com/CrowdStrike/ember-headless-form/commit/69845235c295e05c27ab873cd0af91feebc799c2) Thanks [@NullVoxPopuli](https://github.com/NullVoxPopuli)! - Upgrade dependency: ember-async-data to 1.0.1

- [#132](https://github.com/CrowdStrike/ember-headless-form/pull/132) [`757353d`](https://github.com/CrowdStrike/ember-headless-form/commit/757353de0015e3d10db771dfe41bd366f3a284c7) Thanks [@simonihmig](https://github.com/simonihmig)! - Support reactivity when `@data` is updated

  This supports updates of `@data` (or any of its tracked properties) getting rendered into the form, while previously filled in ("dirty") data is being preserved. This is the implementation for case `#2` of #130.

- [#74](https://github.com/CrowdStrike/ember-headless-form/pull/74) [`eb52f07`](https://github.com/CrowdStrike/ember-headless-form/commit/eb52f0756ed85b34943737248ee0dc569b5408f1) Thanks [@simonihmig](https://github.com/simonihmig)! - Use describedby instead of errormessage ARIA attribute

  Support for `aria-errormessage` is [very incomplete across screen readers](https://a11ysupport.io/tech/aria/aria-errormessage_attribute), therefore switching to the [better supported](https://a11ysupport.io/tech/aria/aria-describedby_attribute), but less specific `aria-describedby`.

## 1.0.0-beta.3

### Patch Changes

- [#136](https://github.com/CrowdStrike/ember-headless-form/pull/136) [`da9f16c`](https://github.com/CrowdStrike/ember-headless-form/commit/da9f16c5165c98c70f3f5caf0042aa162fb435bc) Thanks [@simonihmig](https://github.com/simonihmig)! - Yield `submit` and `reset` actions

  `<HeadlessForm>` yields `submit` and `reset` actions, that can be used in place of the native buttons.

- [#134](https://github.com/CrowdStrike/ember-headless-form/pull/134) [`a3908fc`](https://github.com/CrowdStrike/ember-headless-form/commit/a3908fcf51dc1caa955a355c3e8e2a23d2cc341c) Thanks [@simonihmig](https://github.com/simonihmig)! - Add support for reset button

  Click a native `reset` button will reset the state of the form.

- [#132](https://github.com/CrowdStrike/ember-headless-form/pull/132) [`757353d`](https://github.com/CrowdStrike/ember-headless-form/commit/757353de0015e3d10db771dfe41bd366f3a284c7) Thanks [@simonihmig](https://github.com/simonihmig)! - Support reactivity when `@data` is updated

  This supports updates of `@data` (or any of its tracked properties) getting rendered into the form, while previously filled in ("dirty") data is being preserved. This is the implementation for case `#2` of #130.

## 1.0.0-beta.2

### Patch Changes

- [#80](https://github.com/CrowdStrike/ember-headless-form/pull/80) [`241ccdc`](https://github.com/CrowdStrike/ember-headless-form/commit/241ccdcedaf52d8af8b3f366b61d3055e9e38fc9) Thanks [@simonihmig](https://github.com/simonihmig)! - Add `@ignoreNativeValidation` for opting out of native validation

- [#121](https://github.com/CrowdStrike/ember-headless-form/pull/121) [`fdc4ff9`](https://github.com/CrowdStrike/ember-headless-form/commit/fdc4ff9fd8a2ba00c1f2f1fe04ece8f83ffe97b3) Thanks [@simonihmig](https://github.com/simonihmig)! - Support numbers for Inputs with `@type="number"

  For `@type="number"` Inputs we support passing its value as a real number, and parse and return it as a number as well.

- [#76](https://github.com/CrowdStrike/ember-headless-form/pull/76) [`544509b`](https://github.com/CrowdStrike/ember-headless-form/commit/544509b256fb171e62cc74b2cba2b2f32faa6f35) Thanks [@simonihmig](https://github.com/simonihmig)! - Refactor radio group for better a11y

- [#84](https://github.com/CrowdStrike/ember-headless-form/pull/84) [`67a5169`](https://github.com/CrowdStrike/ember-headless-form/commit/67a5169eb11552d7db9eb1f2553f59dfaad9aa65) Thanks [@simonihmig](https://github.com/simonihmig)! - Convert addon to use template tag

## 1.0.0-beta.1

### Patch Changes

- [#77](https://github.com/CrowdStrike/ember-headless-form/pull/77) [`7c7ff9f`](https://github.com/CrowdStrike/ember-headless-form/commit/7c7ff9f47a24eeddd9ac8f9a4c2643eb5e500582) Thanks [@simonihmig](https://github.com/simonihmig)! - Yield `rawErrors` for custom error rendering

  Both the form and each field yield a `rawErrors` property that gives access to the raw validation error objects for custom error rendering.

- [#74](https://github.com/CrowdStrike/ember-headless-form/pull/74) [`eb52f07`](https://github.com/CrowdStrike/ember-headless-form/commit/eb52f0756ed85b34943737248ee0dc569b5408f1) Thanks [@simonihmig](https://github.com/simonihmig)! - Use describedby instead of errormessage ARIA attribute

  Support for `aria-errormessage` is [very incomplete across screen readers](https://a11ysupport.io/tech/aria/aria-errormessage_attribute), therefore switching to the [better supported](https://a11ysupport.io/tech/aria/aria-describedby_attribute), but less specific `aria-describedby`.

## 1.0.0-beta.0

### Major Changes

- [#34](https://github.com/CrowdStrike/ember-headless-form/pull/34) [`ad9072b`](https://github.com/CrowdStrike/ember-headless-form/commit/ad9072bd02cb38a75a1d05efdfefb88dc827cade) Thanks [@NullVoxPopuli](https://github.com/NullVoxPopuli)! - Initial release
