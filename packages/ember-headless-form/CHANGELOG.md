# ember-headless-form

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
