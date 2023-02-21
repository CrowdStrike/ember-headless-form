# All validations combined

Form-level, field-level and native validation all combined:

```hbs template
<HeadlessForm
  @onSubmit={{this.handleSubmit}}
  @validate={{this.validateEmail}}
  as |form|
>
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
