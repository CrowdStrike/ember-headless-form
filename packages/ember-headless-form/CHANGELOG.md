# ember-headless-form

## 1.0.0-beta.1

### Patch Changes

- [#77](https://github.com/CrowdStrike/ember-headless-form/pull/77) [`7c7ff9f`](https://github.com/CrowdStrike/ember-headless-form/commit/7c7ff9f47a24eeddd9ac8f9a4c2643eb5e500582) Thanks [@simonihmig](https://github.com/simonihmig)! - Yield `rawErrors` for custom error rendering

  Both the form and each field yield a `rawErrors` property that gives access to the raw validation error objects for custom error rendering.

- [#74](https://github.com/CrowdStrike/ember-headless-form/pull/74) [`eb52f07`](https://github.com/CrowdStrike/ember-headless-form/commit/eb52f0756ed85b34943737248ee0dc569b5408f1) Thanks [@simonihmig](https://github.com/simonihmig)! - Use describedby instead of errormessage ARIA attribute

  Support for `aria-errormessage` is [very incomplete across screen readers](https://a11ysupport.io/tech/aria/aria-errormessage_attribute), therefore switching to the [better supported](https://a11ysupport.io/tech/aria/aria-describedby_attribute), but less specific `aria-describedby`.

## 1.0.0-beta.0

### Major Changes

- [#34](https://github.com/CrowdStrike/ember-headless-form/pull/34) [`ad9072b`](https://github.com/CrowdStrike/ember-headless-form/commit/ad9072bd02cb38a75a1d05efdfefb88dc827cade) Thanks [@NullVoxPopuli](https://github.com/NullVoxPopuli)! - Initial release
