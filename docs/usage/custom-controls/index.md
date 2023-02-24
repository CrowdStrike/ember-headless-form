---
title: Custom controls
order: 5
---

# Custom controls

Instead of using the [built-in control components](../controls.md) you can also integrate any existing components. The built-in components give you the benefit that everything is wired up for you automatically though. So when using custom components, you will need to wire some things up explicitly, pertaining data flow and accessible markup.

In the following example we assume a `<CustomInput>` component, that supports `@value` and `@onChange` arguments to pass data into and out of the component. To integrate it into our form, the `Field` component yields:

- `id`: an auto-generated ID that you can set as the `id` of the control, so that the control is correctly associated to its `<label>`, which uses the same ID as its `for` attribute already.
- `value`: the current value of the given field. Pass it to the control.
- `setValue`: an action that receives a (new) value) to set it on the internal form data object. This will make the new value available for [form submission](../data/index.md) and [validation](../../validation/index.md).
