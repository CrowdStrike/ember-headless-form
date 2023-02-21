# Custom control

```hbs template
<HeadlessForm @data={{this.data}} @onSubmit={{this.handleSubmit}} as |form|>
  <form.Field @name='email' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Email</field.Label>
      <CustomInput
        @value={{field.value}}
        @onChange={{field.setValue}}
        id={{field.id}}
        type='email'
        name='email'
        placeholder='Enter your email address'
      />
    </div>
  </form.Field>

  <button type='submit'>Submit</button>
</HeadlessForm>
```

```js component
import Component from '@glimmer/component';

export default class MyFormComponent extends Component {
  data = { email: 'jane.doe@example.com' };

  handleSubmit({ email }) {
    alert(`Form submitted with: ${email}`);
  }
}
```
