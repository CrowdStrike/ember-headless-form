import {} from 'ember-changeset';
import { isChangeset } from 'validated-changeset';

import type { ErrorRecord, FormValidateCallback } from 'ember-headless-form';
import type { EmberChangeset } from 'ember-changeset';
import { assert } from '@ember/debug';

const validateChangeset: FormValidateCallback<EmberChangeset> = async (
  changeset,
  fields
) => {
  assert(
    'Cannot use `validateChangeset` on `@data` that is not a Changeset instance!',
    isChangeset(changeset)
  );

  await Promise.all(fields.map((field) => changeset.validate(field)));

  if (changeset.get('isValid')) {
    return;
  }

  const errorRecord: ErrorRecord<Record<string, unknown>> = {};

  for (const { key, value, validation } of changeset.get('errors')) {
    if (!errorRecord[key]) {
      errorRecord[key] = [];
    }
    const errors = errorRecord[key];

    assert('Expected errorRecord to have array', errors); // TS does not understand errors cannot be undefined at this point

    // some type casting due to https://github.com/validated-changeset/validated-changeset/issues/187
    const fixedValidations = validation as string | string[];

    // aggregate all errors into the ErrorRecord that is expected as the return type of the validate callback
    const messages: string[] = Array.isArray(fixedValidations)
      ? fixedValidations
      : [fixedValidations];
    errors.push(
      ...messages.map((message) => ({ type: 'changeset', value, message }))
    );
  }

  return errorRecord;
};

export default validateChangeset;
