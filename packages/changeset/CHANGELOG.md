# ember-headless-form-changeset

## 1.0.0

### Major Changes

- [#37](https://github.com/CrowdStrike/ember-headless-form/pull/37) [`92b4338`](https://github.com/CrowdStrike/ember-headless-form/commit/92b4338811cd4dbd824f84e018fbd8eb308a5517) Thanks [@simonihmig](https://github.com/simonihmig)! - Add `ember-headless-form-changeset` addon

  Provides a helper that can be used to connect the validation capabilities of a `Changeset` object from [ember-changeset](https://github.com/poteto/ember-changeset) (and thus also [ember-changeset-validations](https://github.com/poteto/ember-changeset-validations/)) to ember-headless-form.

### Patch Changes

- [#118](https://github.com/CrowdStrike/ember-headless-form/pull/118) [`5d75011`](https://github.com/CrowdStrike/ember-headless-form/commit/5d750110000f22460207f963feed3bc7deccd473) Thanks [@simonihmig](https://github.com/simonihmig)! - Fix changeset-helper to work with global resolution

  The previous API worked by passing the helper as-is without actually invoking it: `@validate={{validate-changeset}}`, as the expected return value of the helper is a function itself. But this does not work when globally resolving the helper by its string reference, i.e. when not using `<template>` tag or Embroider. This change fixes the API of the helper, but requires your usage to change from `@validate={{validate-changeset}}` to `@validate={{(validate-changeset)}}`, invoking it without any additional arguments.

  Fixes https://github.com/CrowdStrike/ember-headless-form/issues/109

- Updated dependencies [[`241ccdc`](https://github.com/CrowdStrike/ember-headless-form/commit/241ccdcedaf52d8af8b3f366b61d3055e9e38fc9), [`da9f16c`](https://github.com/CrowdStrike/ember-headless-form/commit/da9f16c5165c98c70f3f5caf0042aa162fb435bc), [`a3908fc`](https://github.com/CrowdStrike/ember-headless-form/commit/a3908fcf51dc1caa955a355c3e8e2a23d2cc341c), [`fdc4ff9`](https://github.com/CrowdStrike/ember-headless-form/commit/fdc4ff9fd8a2ba00c1f2f1fe04ece8f83ffe97b3), [`7c7ff9f`](https://github.com/CrowdStrike/ember-headless-form/commit/7c7ff9f47a24eeddd9ac8f9a4c2643eb5e500582), [`544509b`](https://github.com/CrowdStrike/ember-headless-form/commit/544509b256fb171e62cc74b2cba2b2f32faa6f35), [`67a5169`](https://github.com/CrowdStrike/ember-headless-form/commit/67a5169eb11552d7db9eb1f2553f59dfaad9aa65), [`6984523`](https://github.com/CrowdStrike/ember-headless-form/commit/69845235c295e05c27ab873cd0af91feebc799c2), [`ad9072b`](https://github.com/CrowdStrike/ember-headless-form/commit/ad9072bd02cb38a75a1d05efdfefb88dc827cade), [`757353d`](https://github.com/CrowdStrike/ember-headless-form/commit/757353de0015e3d10db771dfe41bd366f3a284c7), [`eb52f07`](https://github.com/CrowdStrike/ember-headless-form/commit/eb52f0756ed85b34943737248ee0dc569b5408f1)]:
  - ember-headless-form@1.0.0

## 1.0.0-beta.1

### Patch Changes

- [#118](https://github.com/CrowdStrike/ember-headless-form/pull/118) [`5d75011`](https://github.com/CrowdStrike/ember-headless-form/commit/5d750110000f22460207f963feed3bc7deccd473) Thanks [@simonihmig](https://github.com/simonihmig)! - Fix changeset-helper to work with global resolution

  The previous API worked by passing the helper as-is without actually invoking it: `@validate={{validate-changeset}}`, as the expected return value of the helper is a function itself. But this does not work when globally resolving the helper by its string reference, i.e. when not using `<template>` tag or Embroider. This change fixes the API of the helper, but requires your usage to change from `@validate={{validate-changeset}}` to `@validate={{(validate-changeset)}}`, invoking it without any additional arguments.

  Fixes https://github.com/CrowdStrike/ember-headless-form/issues/109

- Updated dependencies [[`241ccdc`](https://github.com/CrowdStrike/ember-headless-form/commit/241ccdcedaf52d8af8b3f366b61d3055e9e38fc9), [`fdc4ff9`](https://github.com/CrowdStrike/ember-headless-form/commit/fdc4ff9fd8a2ba00c1f2f1fe04ece8f83ffe97b3), [`544509b`](https://github.com/CrowdStrike/ember-headless-form/commit/544509b256fb171e62cc74b2cba2b2f32faa6f35), [`67a5169`](https://github.com/CrowdStrike/ember-headless-form/commit/67a5169eb11552d7db9eb1f2553f59dfaad9aa65)]:
  - ember-headless-form@1.0.0-beta.2

## 1.0.0-beta.0

### Major Changes

- [#37](https://github.com/CrowdStrike/ember-headless-form/pull/37) [`92b4338`](https://github.com/CrowdStrike/ember-headless-form/commit/92b4338811cd4dbd824f84e018fbd8eb308a5517) Thanks [@simonihmig](https://github.com/simonihmig)! - Add `ember-headless-form-changeset` addon

  Provides a helper that can be used to connect the validation capabilities of a `Changeset` object from [ember-changeset](https://github.com/poteto/ember-changeset) (and thus also [ember-changeset-validations](https://github.com/poteto/ember-changeset-validations/)) to ember-headless-form.

### Patch Changes

- Updated dependencies [[`ad9072b`](https://github.com/CrowdStrike/ember-headless-form/commit/ad9072bd02cb38a75a1d05efdfefb88dc827cade)]:
  - ember-headless-form@1.0.0-beta.0
