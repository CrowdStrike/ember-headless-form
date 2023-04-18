---
'ember-headless-form-changeset': patch
---

Fix changeset-helper to work with global resolution

The previous API worked by passing the helper as-is without actually invoking it: `@validate={{validate-changeset}}`, as the expected return value of the helper is a function itself. But this does not work when globally resolving the helper by its string reference, i.e. when not using `<template>` tag or Embroider. This change fixes the API of the helper, but requires your usage to change from `@validate={{validate-changeset}}` to `@validate={{(validate-changeset)}}`, invoking it without any additional arguments.

Fixes https://github.com/CrowdStrike/ember-headless-form/issues/109
