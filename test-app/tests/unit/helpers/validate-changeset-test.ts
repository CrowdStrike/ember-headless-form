import { module, test } from 'qunit';

import { Changeset } from 'ember-changeset';
import { validateChangeset } from 'ember-headless-form-changeset';

import type { ValidatorAction } from 'ember-changeset/types';

module('Unit | Helpers | validate-changeset', function () {
  const validator: ValidatorAction = ({ key, newValue }) => {
    const errors: string[] = [];

    if (newValue == undefined) {
      errors.push(`${key} is required!`);
    } else if (typeof newValue !== 'string') {
      errors.push('Unexpected type');
    } else {
      if (newValue.charAt(0).toUpperCase() !== newValue.charAt(0)) {
        errors.push(`${key} must be upper case!`);
      }

      if (newValue.toLowerCase() === 'foo') {
        errors.push(`Foo is an invalid ${key}!`);
      }
    }

    return errors.length > 0 ? errors : true;
  };

  const validate = validateChangeset();

  test('it returns undefined if validation passes', async function (assert) {
    const changeset = Changeset({ firstName: 'Nicole' }, validator);

    let result = await validate(changeset, ['firstName']);

    assert.strictEqual(result, undefined);
  });

  test('it returns error record if validation fails', async function (assert) {
    const changeset = Changeset(
      { firstName: 'foo', lastName: 'Smith' },
      validator
    );

    let result = await validate(changeset, ['firstName', 'lastName', 'email']);

    assert.deepEqual(result, {
      firstName: [
        {
          type: 'changeset',
          value: 'foo',
          message: 'firstName must be upper case!',
        },
        {
          type: 'changeset',
          value: 'foo',
          message: 'Foo is an invalid firstName!',
        },
      ],
      email: [
        { type: 'changeset', value: undefined, message: 'email is required!' },
      ],
    });
  });
});
