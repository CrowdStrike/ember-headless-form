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

## Checkbox group

Renders `<input type="checkbox">` form elements, wrapped in a `<div role="group">`. One or multiple checkboxes form a group. Data assigned to that field should be an array of type `string`.

You may use one or multiple instances of `Checkbox`, yielded from `CheckboxGroup`. Each of those will itself yield additional sub-components `Input` (for rendering the actual `<input`) and `Label` (for the `<label>` associated to the `Input`). Pass `@value` to the `Checkbox`, determining the value of the field's form data when that checkbox is selected. Make sure to also use a `Label` for the checkbox group:

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='likes' as |field|>
    <field.CheckboxGroup class='my-2 flex flex-col' as |group|>
      <group.Label>I like:</group.Label>
      <div class='flex flex-row space-x-2'>
        <group.Checkbox @value='red' as |checkbox|>
          <checkbox.Input />
          <checkbox.Label>Red</checkbox.Label>
        </group.Checkbox>
        <group.Checkbox @value='green' as |checkbox|>
          <checkbox.Input />
          <checkbox.Label>Green</checkbox.Label>
        </group.Checkbox>
        <group.Checkbox @value='blue' as |checkbox|>
          <checkbox.Input />
          <checkbox.Label>Blue</checkbox.Label>
        </group.Checkbox>
      </div>
    </field.CheckboxGroup>
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

## Localized Number

This will render a text input that attempts to format a number using a given Locale and number options. You would set `@locale` to something like `"en-US"` and `@formatOptions` would contain the [options that you would typically pass to a Intl.NumberFormat constructor](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat/NumberFormat). The supported options are `decimal`, `currency`, `percent`, and sometimes `unit` depending on the specified locale. If no locale is specified it will use the user's locale set by `navigator.language`.

### Return Values
The value that is set on the given data will always be a number. Meaning something like `"1 234,56 $US"` when formatting for US Dollars with a French Locale will set the actual data to `1234.56`. What is shown in the text box is a display to the user. As for percentages, those are returned as numbers, meaning `"10%"` will set the value to `0.10`. 

```hbs
<HeadlessForm as |form|>
  <form.Field @name='donation' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>
        How much would you like to donate?
      </field.Label>
      <field.LocalNumber
        class='border rounded px-2'
        @locale='en-US'
        @formatOptions={{hash style='currency' currency='USD'}}
        required
      />
    </div>
  </form.Field>
</HeadlessForm>
```