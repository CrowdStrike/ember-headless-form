---
title: Styling
order: 4
---

# Applying styles

some text

```hbs preview-template
<HeadlessForm as |form|>
  <form.Field @name='firstName' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>First name</field.Label>
      <field.Input class='border rounded px-2' required />
    </div>
  </form.Field>

  <form.Field @name='lastName' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Last name</field.Label>
      <field.Input class='border rounded px-2' required />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```
