---
'ember-headless-form': patch
---

Support reactivity when `@data` is updated

This supports updates of `@data` (or any of its tracked properties) getting rendered into the form, while previously filled in ("dirty") data is being preserved. This is the implementation for case `#2` of #130.
