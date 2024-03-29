---
title: Controls
order: 4
---

# Form controls

Controls as we use the term here refer to the UI widgets that allow a user to enter data. In its most basic form that would be an `<input>`.

ember-headless-form comes with support for the following controls built-in (but you can also use [custom controls](./custom-controls/index.md)), all yielded from the `Field` component:

## Input

Renders a basic `<input>` element. Set `@type` to any of the supported [input types](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#input_types) other than the default `text`.

Note that `checkbox` and `radio` should not be used, as they have dedicated control components (see below).
Also these types are not useful to use as input controls: `button`,`file`,`image`,`reset`,`submit`.

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='email' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Email</field.Label>
      <field.Input
        @type='email'
        placeholder='Enter your email address'
        class='border rounded px-2'
      />
    </div>
  </form.Field>

  <form.Field @name='birthday' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Birthday</field.Label>
      <field.Input @type='date' class='border rounded px-2' />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```

## Textarea

Renders a `<textarea>` form element.

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='comment' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Comment</field.Label>
      <field.Textarea class='border rounded px-2' />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```

## Checkbox

Renders a single `<input type="checkbox">` form element. Note that form data assigned to that field should have a `boolean` type.

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='accept_tos' as |field|>
    <div class='my-2 flex flex-row space-x-2'>
      <field.Checkbox />
      <field.Label>I accept the Terms of Service</field.Label>
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```

## Radio group

Renders `<input type="radio">` form elements, wrapped in a `<div role="radiogroup">`. Using a single control is not useful here, instead multiple radio buttons form a radio group. As such the usage pattern differs from previous examples.

You will have to use multiple instances of `Radio`, yielded from `RadioGroup`. Each of those will itself yield additional sub-components `Input` (for rendering the actual `<input`) and `Label` (for the `<label>` associated to the `Input`). Pass `@value` to the `Radio`, determining the value of the field's form data when that radio button is selected. Make sure to also use a `Label` for the radio group:

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='gender' as |field|>
    <field.RadioGroup class='my-2 flex flex-col' as |group|>
      <group.Label>Payment method:</group.Label>
      <div class='flex flex-row space-x-2'>
        <group.Radio @value='cc_master' as |radio|>
          <radio.Input />
          <radio.Label>Mastercard</radio.Label>
        </group.Radio>
        <group.Radio @value='cc_visa' as |radio|>
          <radio.Input />
          <radio.Label>Visa</radio.Label>
        </group.Radio>
        <group.Radio @value='paypal' as |radio|>
          <radio.Input />
          <radio.Label>Paypal</radio.Label>
        </group.Radio>
      </div>
    </field.RadioGroup>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```

## Select

Renders a native `<select>` dropdown. It will yield another `Option` component for the individual options, which receives a `@value` and the visible label as the block content, just like the native `<option>` element.

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='country' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Country</field.Label>
      <field.Select class='border rounded px-2' as |select|>
        <select.Option @value=''>Please select...</select.Option>
        <select.Option @value='USA'>United States</select.Option>
        <select.Option @value='CA'>Canada</select.Option>
        <select.Option @value='GER'>Germany</select.Option>
      </field.Select>
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```
