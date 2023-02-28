# Getting data into and out of the form

```hbs template
<HeadlessForm @data={{this.data}} @onSubmit={{this.handleSubmit}} as |form|>
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

```js component
import Component from '@glimmer/component';

export default class MyFormComponent extends Component {
  data = {
    firstName: 'Jane',
    lastName: 'Doe',
  };

  handleSubmit({ firstName, lastName }) {
    alert(`Form submitted with: ${firstName} ${lastName}`);
  }
}
```
