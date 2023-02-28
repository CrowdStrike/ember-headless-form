---
title: Usage
order: 1
---

# Basic usage

ember-headless-form exposes only a single component as its public API, `<HeadlessForm>`. All its other ingredients are yielded, as contextual components, modifiers or plain data.

Every form is composed of one or multiple _fields_. A field is considered a single item of the form that the user can enter data for, identified by its _name_, and consisting of at least a _control_ and its label. The [control](./controls.md) is then the form element that the user will interact with to enter the data, like an `<input>` or `<select>`. To finally submit the form, a button of type `submit` is needed.

These pieces make up the most basic example of a form:

```hbs
<HeadlessForm as |form|>
  <form.Field @name='firstName' as |field|>
    <field.Label>First name</field.Label>
    <field.Input />
  </form.Field>

  <form.Field @name='lastName' as |field|>
    <field.Label>Last name</field.Label>
    <field.Input />
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```
