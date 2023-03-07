---
'ember-headless-form': patch
---

Use describedby instead of errormessage ARIA attribute

Support for `aria-errormessage` is [very incomplete across screen readers](https://a11ysupport.io/tech/aria/aria-errormessage_attribute), therefore switching to the [better supported](https://a11ysupport.io/tech/aria/aria-describedby_attribute), but less specific `aria-describedby`.
