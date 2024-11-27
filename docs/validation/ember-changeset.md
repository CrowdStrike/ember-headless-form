---
title: ember-changeset
order: 6
---

# Integrating with `ember-changeset`

The [`ember-changeset`](https://github.com/poteto/ember-changeset) addon provides validation capabilities, either directly or using [`ember-changeset-validations`](https://github.com/poteto/ember-changeset-validations/).
With the optional `ember-headless-form-changeset` package you can easily integrate those into ember-headless-form.

In the following we will be assuming you use `ember-changeset-validations` to define the validation rules. So if you haven't done so already, install `ember-changeset` and `ember-changeset-validations` according to their documentation. Then install `ember-headless-form-changeset`:

```bash
pnpm add ember-headless-form-changeset
# or
yarn add ember-headless-form-changeset
# or
npm install ember-headless-form-changeset
```

Next we need to define the validation map using their provided validator functions, again refer to their [documentation](https://github.com/poteto/ember-changeset-validations/#usage).

Finally we need to integrate the changeset and the validation map with the validation capabilities of the form:

- pass the `Changeset` instance to the form's `@data`. Usually you will do this using the `{{changeset}}` helper, passing both the original data object as well as the validation map
- the `ember-headless-form-changeset` addon provides a single `validate-changeset` helper, that provides the glue code to map the `ember-changeset` validation errors to the format ember-headless-form expects. Apply it to the [`@validate` form-level callback](./custom-validation.md#form-level-validation).
- as we need to apply all interim changes of the form data by the user to the `Changeset`, so that its validations can operate on the changed values, we need to [opt into mutable mode](../usage/data/index.md#im-mutable-data) by setting `@dataMode="mutable"`.

See the following example, where the form's validation is entirely delegated to the validations provided by `ember-changeset-validations`:

### Using another changeset

Sometimes you will need to use a changeset from the parent web page or component. In this case, the simplest thing to do is create the changeset in the parent and pass it to the `@data` arg:

```diff
{{!-- in the template --}}
- @data={{changeset this.data this.validations}}
+ @data={{this.changeset}}
```

```javascript
// in the backing class
import Component from '@glimmer/component';
import EmployeeValidations from '../validations/employee';
import lookupValidator from 'ember-changeset-validations';
import Changeset from 'ember-changeset';

export default class ChangesetComponent extends Component {
  changeset = new Changeset(
    this.model,
    lookupValidator(EmployeeValidations),
    EmployeeValidations
  );
}
```
