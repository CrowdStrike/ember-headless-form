---
'ember-headless-form': patch
---

Fixes a bug where if the submit button is clicked multiple times with async validation present the submit callback would trigger. Now if there is pending validation the submit will be cancelled to avoid extra calls.
