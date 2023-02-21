---
title: Custom validation
order: 3
---

# Adding custom JavaScript-based validation

When you reach the limits of [native validation](./native.md) or have needs for more customization, you can use custom JavaScript-based validation. The basic mode of operation is that whenever validation needs to happen (see [Validation timing](./timing.md)) a callback function you provide is called, which is supposed to just return (`undefined`) when there are no validation errors, or otherwise return the list of [`ValidationError` objects](./index.md#validation-errors).

## Form level validation

You can pass a _form level_ validation callback to the form via the `@validate` argument. Form level means that it will be called for the whole form data object, and when invalid needs to return an [`ErrorRecord`](./index.md#validation-errors) mapping the invalid field names to their respective array of `ValidationError`s. This is especially useful if you already have a way to validate your data object which the form represents, as with some kind of schema-based validation. (e.g. [yup](./yup.md) or [ember-changeset](./ember-changeset.md))

See the [form-level example](#docfy-demo-validation-custom-validation-form-level) and its `validateEmail` function for an example.

## Field level validation

The `Field` component also supports a `@validate` argument, which is only called for that specific field. It will receive as arguments the current value, the name of the field and the current form data object. In the invalid case it needs to return an array of [`ValidationError`](./index.md#validation-errors).

See the [field-level example](#docfy-demo-validation-custom-validation-field-level) and its `validateEmailHost` function for an example.

## Validation error merging

We now have learned about three sources of validation errors: [native validation](./native.md) as well as [form-level](#form-level-validation) and [field-level](#field-level-validation) custom validation. And these sources are not mutually-exclusive, but can actually combined together. ember-headless-form will merge validation errors coming from all these sources together, make them all available when [rendering validation errors](./index.md#rendering-validation-errors).

This allows you for example to cover the basic validation requirements like `required` fields or specific input types using native validation, while adding more complex validations using custom validation that cannot be expressed with the native capabilities.

See the [combined example](#docfy-demo-validation-custom-validation-combined) for an example where all validation types are working together.

## Asynchronous validation

In the examples above we only dealt with synchronous validation, which usually will cover most needs. But ember-headless-form also supports async validation functions. So when the function returns the `ValidationError` array or the `ErrorRecord` wrapped in a `Promise`, it will correctly await that before proceeding. This allows you to add validations that need to be async in nature. For example to check the validity of a username not being taken already during signing up, you can have an async validation function that sends a `fetch` request to some API endpoint.
