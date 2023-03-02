import type {
  ErrorRecord,
  FormKey,
  FormValidateCallback,
} from '@crowdstrike/ember-headless-form';
import { assert } from '@ember/debug';

import type { ObjectSchema, ValidationError } from 'yup';

/**
 * Validation helper for integrating `yup` based validations into headless forms.
 *
 * Pass this to the `@validate` hook, supplying the `yup` schema as the only argument: `@validate={{validateYup schema}}`.
 */
export default function validateChangeset<DATA extends object>(
  schema: ObjectSchema<DATA>
): FormValidateCallback<Partial<DATA>> {
  return async (formData) => {
    try {
      await schema.validate(formData, { abortEarly: false });
    } catch (e) {
      const validationError = e as ValidationError;
      const errorRecord: ErrorRecord<DATA> = {};

      for (const { path, type, value, message } of validationError.inner) {
        assert(
          'Received undefined path for yup validation error. If you see this, please report it as a bug to ember-headless-form!',
          path !== undefined
        );
        const key = path as FormKey<DATA>; // yup maybe could have stricter types here, as path will always refer to a key of its schema

        if (!errorRecord[key]) {
          errorRecord[key] = [];
        }

        const errors = errorRecord[key];
        assert('Expected errorRecord to have array', errors); // TS does not understand errors cannot be undefined at this point

        errors.push({
          type: type ?? 'unknown',
          value,
          message,
        });
      }

      return errorRecord;
    }

    return undefined;
  };
}
