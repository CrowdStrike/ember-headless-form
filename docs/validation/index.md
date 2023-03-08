---
title: Introduction
order: 1
---

# Validation

Client side validation is a first-class citizen of ember-headless-form, supporting both [native HTML validation](./native.md) as well as JavaScript-based [custom validation](./custom-validation.md).

See the following chapters for how to integrate the different kinds of validation. Common to all of them is how they affect what happens when a [form is submitted](../usage/data/index.md#getting-data-out). Upon submitting the form, the `@onSubmit` action is called. When the form has validation in place, it will only be called when the validation has passed. Otherwise `@onInvalid` is called, which receives the invalid form data object, alongside an `ErrorRecord` object.

## Validation Errors

Internally, but also when creating [custom validations](./custom-validation.md) or [rendering validation errors](#rendering-validation-errors), validation errors are represented with the following structure:

```ts
interface ValidationError<T> {
  type: string; // identifier for the type of error (depending on the validation solution that generated the error)
  value: T; // the (invalid) value
  message?: string; // a ready to use message for users, not always present (depending on the validation solution that generated the error))
}
```

An `ErrorRecord` is just a record or dictionary, mapping (invalid) field names to an array of `ValidationError`. So in TypeScript syntax basically a `Record<KEY, ValidationError<DATA[KEY]>[]>` (the _actual_ type definition is a bit more verbose, but that does not matter here).

## Rendering validation errors

For rendering validation errors next to the field that caused them, the `Field` component yields another contextual component `Errors`. In non-block form, it will automatically render all the field's error messages:

```hbs
<HeadlessForm as |form|>
  <form.Field @name='firstName' as |field|>
    <field.Label>First name</field.Label>
    <field.Input required />
    <field.Errors />
  </form.Field>
  <button type='submit'>Submit</button>
</HeadlessForm>
```

In block-mode it will yield the raw `ValidationError` objects as described above, which let's you apply any custom rendering logic. In the following example we pass the errors `type` and `value` to a `{{t}}` helper (like that provided by `ember-intl`) to generate a translated user-friendly message:

```hbs
<HeadlessForm as |form|>
  <form.Field @name='firstName' as |field|>
    <field.Label>First name</field.Label>
    <field.Input required />
    <field.Errors as |errors|>
      {{#each errors as |e|}}
        {{t e.type value=e.value}}<br />
      {{/each}}
    </field.Errors>
  </form.Field>
  <button type='submit'>Submit</button>
</HeadlessForm>
```

For rendering other markup based on the current validation state, both the form itself as well as each field yields an `isInvalid` property:

```hbs
<HeadlessForm as |form|>
  {{#if form.isInvalid}}
    <p>Fix all form validation errors below before submitting again!</p>
  {{/if}}
  <form.Field @name='firstName' as |field|>
    <field.Label>First name</field.Label>
    <field.Input required class={{if field.isInvalid 'has-errors'}} />
    <field.Errors />
  </form.Field>
  <button type='submit'>Submit</button>
</HeadlessForm>
```

If you prefer to not use the yielded `<field.Errors>` component for error rendering, you can use the raw `ValidationError` objects instead to render them on your own. They are yielded as `rawErrors`

- from the form, as an `ErrorRecord` for all fields
- from each field as an array of `ValidationError`s
