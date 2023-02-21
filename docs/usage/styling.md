---
title: Styling
order: 2
---

# Applying styles

While this addon does render the most basic semantic and accessible form markup, it is still _headless_ in the sense that it has no opinions on any additional markup or its styling. This is your own responsibility, and the addon tries to get out of your way.

The components that render markup, like the labels or controls, all use `...attributes` to let you customize their default elements by adding your own classes or any other HTML attributes. The `Field` component does not render any markup on its own, but you are free to add your own elements as you wish, e.g. by wrapping the control and its label in a `<div>`. By only yielding components you are also free to use them&mdash;in any order you want&mdash;or instead use your own markup or components, like [custom controls](./custom-controls.md).

Here is a simple example applying a set of basic TailwindCSS classes:

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='firstName' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>First name</field.Label>
      <field.Input class='border rounded px-2' />
    </div>
  </form.Field>

  <form.Field @name='lastName' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Last name</field.Label>
      <field.Input class='border rounded px-2' />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```
