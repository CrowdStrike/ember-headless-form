import type { ErrorRecord, FormData, FormKey, ValidationError } from './types';

export function mergeErrorRecord<
  DATA extends FormData,
  KEY extends FormKey<DATA> = FormKey<DATA>
>(
  ...records: Array<ErrorRecord<DATA, KEY> | undefined>
): ErrorRecord<DATA, KEY> {
  const errors: ErrorRecord<DATA, KEY> = {};

  for (const record of records) {
    if (!record) {
      continue;
    }

    for (const [name, fieldErrors] of Object.entries(record) as [
      // TS does not infer the types correctly here, fieldErrors would be unknown, not sure why
      KEY,
      ValidationError<DATA[KEY]>[]
    ][]) {
      const existingFieldErrors = errors[name];

      errors[name] = existingFieldErrors
        ? [...existingFieldErrors, ...fieldErrors]
        : fieldErrors;
    }
  }

  return errors;
}
