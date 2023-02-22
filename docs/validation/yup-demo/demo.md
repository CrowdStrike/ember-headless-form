# Integrating `yup` validation

Using a yup schema to validate a form.

```hbs template
<HeadlessForm
  @onSubmit={{this.handleSubmit}}
  @validate={{validate-yup this.schema}}
  as |form|
>
  <form.Field @name='name' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Name</field.Label>
      <field.Input class='border rounded px-2' />
      <field.Errors />
    </div>
  </form.Field>

  <form.Field @name='email' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Email</field.Label>
      <field.Input class='border rounded px-2' />
      <field.Errors />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```

```js component
import Component from '@glimmer/component';
import { object, string } from 'yup';

export default class MyFormComponent extends Component {
  schema = object({
    name: string().required(),
    email: string().required().email(),
  });

  handleSubmit({ name, email }) {
    alert(`Form submitted with: ${name} ${email}`);
  }
}
```
