---
title: Timing
order: 4
---

# Timing of dynamic validation

In the most basic way validation will happen whenever you try to submit a form. This is the way how server-rendered apps without any native validation or JavaScript worked for a long time. And in fact, ember-headless-form enforces validation whenever you try to submit the form.

But in addition to that, as our app is running client-side, we can do validation even earlier, for example whenever an input was changed. This is what we call dynamic validation here.

By default validation will happen:

- initially, when you try to submit
- on "revalidation", when a field is in an invalid state (due to a prior submission attempt), and the user changes its value (a `change` event is fired from the control)

In the following example, when you enter an invalid email address like `foo`, nothing will happen until you press the submit button. When pressing the submit button the email field will become invalid and show the (native) error message. When you fix it to be a real email _and_ move focus out of the input (which triggers a `change` event), you will see that the validation error is immediately removed:

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='email' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Email</field.Label>
      <field.Input @type='email' required class='border rounded px-2' />
      <field.Errors />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```

## `@validateOn`

You can customize the first part of _initial_ validation by passing the `@validateOn` argument to the form. It accepts one of these values: (sorted in order how frequently the events happen)

- `submit`: validate when submitting the form. This is the default.
- `focusout`: validate whenever a control looses focus.
- `change`: validate whenever a control triggers a `change` event.

  Important to note: when a control emits a `change` event depends on its type: for selection-based controls like checkboxes, radios or selects, that happens whenever the selected value changes. For text-based inputs this only happens after loosing focus! See [change event](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/change_event)

- `input`: validate whenever the entered value changes. This is different from `change` in that it happens on _every_ change to the value, e.g. on every key stroke for a text-based input.

## `@revalidateOn`

This argument is similar to `@validateOn`, but it affects the later revalidation, i.e. when a field is already in an invalid state due to prior validation. It accepts the same possible values as `@validateOn`.

While `@validateOn` affects all fields, `@revalidateOn` only affects the subset of fields that are already marked as invalid. As such the idea here is to make this happen _more eagerly_ than `@validateOn`.

In the following example, we changed our previous form to validate on `focusout`, and revalidate on `input`. Entering an invalid email address and removing focus will immediately show the validation error, even without submitting. Then when focussing the email control again and typing, it will update or remove the validation error on every key stroke:

```hbs preview-template
<HeadlessForm @validateOn='focusout' @revalidateOn='input' as |form|>
  <form.Field @name='email' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Email</field.Label>
      <field.Input @type='email' required class='border rounded px-2' />
      <field.Errors />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```
