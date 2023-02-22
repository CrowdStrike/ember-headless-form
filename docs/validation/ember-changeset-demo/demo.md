# Integrating `ember-changeset` validation

Using a Changeset instance to validate a form.

```hbs template
<HeadlessForm
  @data={{changeset this.data this.validations}}
  @dataMode='mutable'
  @onSubmit={{this.handleSubmit}}
  @validate={{validate-changeset}}
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
import {
  validatePresence,
  validateFormat,
} from 'ember-changeset-validations/validators';

export default class MyFormComponent extends Component {
  data = {};

  validations = {
    name: validatePresence(true),
    email: validateFormat({ type: 'email' }),
  };

  handleSubmit({ name, email }) {
    alert(`Form submitted with: ${name} ${email}`);
  }
}
```
