# Form level validation

This demo shows how to apply a validator function to the whole form. It receives the form data, and returns a validation error if the two email fields do not match.

```hbs template
<HeadlessForm
  @onSubmit={{this.handleSubmit}}
  @validate={{this.validateEmail}}
  as |form|
>
  <form.Field @name='email' as |field|>
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

  <form.Field @name='email_confirmation' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Email (enter again)</field.Label>
      <field.Input
        @type='email'
        required
        placeholder='Please enter your email again to confirm'
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
  validateEmail = ({ email, email_confirmation }) => {
    if (email !== email_confirmation) {
      return {
        email_confirmation: [
          {
            type: 'emailConfirmationMatch',
            value: email_confirmation,
            message: `Entered email addresses do not match: ${email} does not equal ${email_confirmation}`,
          },
        ],
      };
    }
  };

  handleSubmit({ email }) {
    alert(`Form submitted with: ${email}`);
  }
}
```
