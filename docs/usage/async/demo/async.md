# Async state

Submit this form with a valid email, and with the same email again, to see how it disables the submit button, changes its label, and shows error messages coming from the "backend":

```hbs template
<HeadlessForm @onSubmit={{this.handleSubmit}} as |form|>
  <form.Field @name='email' as |field|>
    <div class='my-2 flex flex-col'>
      <field.Label>Email</field.Label>
      <field.Input
        @type='email'
        placeholder='Please enter your email'
        class='border rounded px-2'
      />
    </div>
  </form.Field>

  <button type='submit' disabled={{form.submissionState.isPending}}>
    {{if form.submissionState.isPending 'Submitting...' 'Submit'}}
  </button>

  {{#if form.submissionState.isResolved}}
    <p>We got your data! 🎉</p>
  {{else if form.submissionState.isRejected}}
    <p>⛔️ {{form.submissionState.error}}</p>
  {{/if}}
</HeadlessForm>
```

```js component
import Component from '@glimmer/component';
import { action } from '@ember/object';

export default class MyFormComponent extends Component {
  saved = [];

  @action
  async handleSubmit({ email }) {
    // pretending something async is happening here
    await new Promise((r) => setTimeout(r, 3000));

    if (!email) {
      throw new Error('No email given');
    }

    if (this.saved.includes(email)) {
      throw new Error(`${email} is already taken!`);
    }

    this.saved.push(email);
  }
}
```
