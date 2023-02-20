---
title: Usage
order: 1
---

# Usage

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
