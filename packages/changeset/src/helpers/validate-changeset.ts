import { isChangeset } from 'validated-changeset';

import type {
  ErrorRecord,
  FormValidateCallback,
} from '@crowdstrike/ember-headless-form';
import type { EmberChangeset } from 'ember-changeset';
import { assert } from '@ember/debug';

/**
 * Validation helper for integrating `ember-changeset` based validations into headless forms:
 *
 * - pass a changeset to the form's `@data`
 * - pass this helper into the form's `@validate` hook `@validate={{validateChangeset}}`
 * - opt-in to `@dataMode="mutable"`
 */
const validateChangeset: FormValidateCallback<EmberChangeset> = async (
  changeset,
  fields
) => {
  assert(
    'Cannot use `validateChangeset` on `@data` that is not a Changeset instance!',
    isChangeset(changeset)
  );

  // there is also an argument-less version of changeset.validate(), but for this to work the changeset needs a so called validationMap, and not just a validator function
  // while ember-changeset-validations would provide such a map, we cannot necessarily rely on it being present, so the way to reliably validate all fields is to iterate
  // over them explicitly
  //
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
