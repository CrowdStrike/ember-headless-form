# Field level validation

Here we apply a validation function directly to a field, checking only the validity of that single field.

```hbs template
<HeadlessForm @onSubmit={{this.handleSubmit}} as |form|>
  <form.Field @name='email' @validate={{this.validateEmailHost}} as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Email</field.Label>
      <field.Input
        @type='email'
        required
        placeholder='Enter your email address'
        class='border rounded px-2'
      />
      <field.Errors />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```

```js component
import Component from '@glimmer/component';

export default class MyFormComponent extends Component {
  validateEmailHost = (email) => {
    if (email && !email.endsWith('@example.com')) {
      return [
        {
          type: 'emailHostInvalid',
          value: email,
          message: 'Email address must belong to example.com!',
        },
      ];
    }
  };

  handleSubmit({ email }) {
    alert(`Form submitted with: ${email}`);
  }
}
```
