import { module, test } from 'qunit';

import { validateYup } from '@crowdstrike/ember-headless-form-yup';
import { object, string } from 'yup';

module('Unit | Helpers | validate-yup', function () {
  const schema = object({
    firstName: string()
      .required()
      .notOneOf(['Foo'], 'Foo is an invalid firstName!'),
    lastName: string()
      .required()
      .notOneOf(['Foo'], 'Foo is an invalid lastName!'),
    email: string().email(),
  });

  const validator = validateYup(schema);

  test('it returns undefined if validation passes', async function (assert) {
    let result = await validator({ firstName: 'Nicole', lastName: 'Chung' }, [
      'firstName',
      'lastName',
    ]);

    assert.strictEqual(result, undefined);
  });

  test('it returns error record if validation fails', async function (assert) {
    let result = await validator(
      { firstName: 'Foo', lastName: 'Smith', email: 'bar' },
      ['firstName', 'lastName']
    );

    assert.deepEqual(result, {
      firstName: [
        {
          type: 'notOneOf',
          value: 'Foo',
          message: 'Foo is an invalid firstName!',
        },
      ],
      email: [
        { type: 'email', value: 'bar', message: 'email must be a valid email' },
      ],
    });
  });
});
