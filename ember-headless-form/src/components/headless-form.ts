import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { assert } from '@ember/debug';
import { on } from '@ember/modifier';
import { action } from '@ember/object';

import { TrackedObject } from 'tracked-built-ins';

import FieldComponent from './-private/field';

import type { HeadlessFormFieldComponentSignature } from './-private/field';
import type {
  ErrorRecord,
  FieldRegistrationData,
  FieldValidateCallback,
  FormData,
  FormKey,
  FormValidateCallback,
  UserData,
  ValidationError,
} from './-private/types';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

type ValidateOn = 'change' | 'blur' | 'submit';

export interface HeadlessFormComponentSignature<DATA extends UserData> {
  Element: HTMLFormElement;
  Args: {
    data?: DATA;
    validateOn?: ValidateOn;
    revalidateOn?: ValidateOn;
    validate?: FormValidateCallback<FormData<DATA>>;
    onSubmit?: (data: FormData<DATA>) => void;
    onInvalid?: (
      data: FormData<DATA>,
      errors: ErrorRecord<FormData<DATA>>
    ) => void;
  };
  Blocks: {
    default: [
      {
        field: WithBoundArgs<
          typeof FieldComponent<DATA>,
          'data' | 'set' | 'errors' | 'registerField' | 'unregisterField'
        >;
      }
    ];
  };
}

class FieldData<
  DATA extends FormData,
  KEY extends FormKey<DATA> = FormKey<DATA>
> {
  constructor(fieldRegistration: FieldRegistrationData<DATA, KEY>) {
    this.validate = fieldRegistration.validate;
  }

  @tracked validationEnabled = false;

  validate?: FieldValidateCallback<DATA, KEY>;
}

export default class HeadlessFormComponent<
  DATA extends UserData
> extends Component<HeadlessFormComponentSignature<DATA>> {
  FieldComponent: ComponentLike<HeadlessFormFieldComponentSignature<DATA>> =
    FieldComponent;

  // we cannot use (modifier "on") directly in the template due to https://github.com/emberjs/ember.js/issues/19869
  on = on;

  internalData: DATA = new TrackedObject(this.args.data ?? {}) as DATA;

  fields = new Map<FormKey<FormData<DATA>>, FieldData<FormData<DATA>>>();

  @tracked lastValidationResult?: ErrorRecord<FormData<DATA>>;
  @tracked showAllValidations = false;

  get validateOn(): ValidateOn {
    return this.args.validateOn ?? 'submit';
  }

  get revalidateOn(): ValidateOn {
    return this.args.revalidateOn ?? 'change';
  }

  get fieldValidationEvent(): 'focusout' | 'change' | undefined {
    const { validateOn } = this;

    return validateOn === 'submit'
      ? // no need for dynamic validation, as validation always happens on submit
        undefined
      : // our component API expects "blur", but the actual blur event does not bubble up, so we use focusout internally instead
      validateOn === 'blur'
      ? 'focusout'
      : validateOn;
  }

  get fieldRevalidationEvent(): 'focusout' | 'change' | undefined {
    const { validateOn, revalidateOn } = this;

    return revalidateOn === 'submit'
      ? // no need for dynamic validation, as validation always happens on submit
        undefined
      : // when validation happens more frequently than revalidation, then we can ignore revalidation, because the validation handler will already cover us
      validateOn === 'change' ||
        (validateOn === 'blur' && revalidateOn === 'blur')
      ? undefined
      : // our component API expects "blur", but the actual blur event does not bubble up, so we use focusout internally instead
      revalidateOn === 'blur'
      ? 'focusout'
      : revalidateOn;
  }

  get hasValidationErrors(): boolean {
    // Only consider validation errors for which we actually have a field rendered
    return this.lastValidationResult
      ? Object.keys(this.lastValidationResult).some((name) =>
          this.fields.has(name as FormKey<FormData<DATA>>)
        )
      : false;
  }

  async validate(): Promise<ErrorRecord<FormData<DATA>> | undefined> {
    let errors: ErrorRecord<FormData<DATA>> | undefined = undefined;

    if (this.args.validate) {
      errors = await this.args.validate(this.internalData);
    }

    if (!errors) {
      errors = {};
    }

    for (const [name, field] of this.fields) {
      const fieldValidation = await field.validate?.(
        this.internalData[name],
        name,
        this.internalData
      );

      if (fieldValidation) {
        const existingFieldErrors = errors[name];

        errors[name] = existingFieldErrors
          ? [...existingFieldErrors, ...fieldValidation]
          : fieldValidation;
      }
    }

    return Object.keys(errors).length > 0 ? errors : undefined;
  }

  get visibleErrors(): ErrorRecord<FormData<DATA>> | undefined {
    if (!this.lastValidationResult) {
      return undefined;
    }

    const visibleErrors: ErrorRecord<FormData<DATA>> = {};

    for (const [field, errors] of Object.entries(this.lastValidationResult) as [
      FormKey<FormData<DATA>>,
      ValidationError<FormData<DATA>[FormKey<FormData<DATA>>]>[]
    ][]) {
      if (this.showErrorsFor(field)) {
        visibleErrors[field] = errors;
      }
    }

    return visibleErrors;
  }

  showErrorsFor(field: FormKey<FormData<DATA>>): boolean {
    return (
      this.showAllValidations ||
      (this.fields.get(field)?.validationEnabled ?? false)
    );
  }

  @action
  async onSubmit(e: Event): Promise<void> {
    e.preventDefault();

    this.lastValidationResult = await this.validate();
    this.showAllValidations = true;

    if (!this.hasValidationErrors) {
      this.args.onSubmit?.(this.internalData);
    } else {
      assert(
        'Validation errors expected to be present. If you see this, please report it as a bug to ember-headless-form!',
        this.lastValidationResult
      );
      this.args.onInvalid?.(this.internalData, this.lastValidationResult);
    }
  }

  @action
  registerField(
    name: FormKey<FormData<DATA>>,
    field: FieldRegistrationData<FormData<DATA>>
  ): void {
    assert(
      `You passed @name="${String(
        name
      )}" to the form field, but this is already in use. Names of form fields must be unique!`,
      !this.fields.has(name)
    );
    this.fields.set(name, new FieldData(field));
  }

  @action
  unregisterField(name: FormKey<FormData<DATA>>): void {
    this.fields.delete(name);
  }

  @action
  set<KEY extends FormKey<FormData<DATA>>>(key: KEY, value: DATA[KEY]): void {
    this.internalData[key] = value;
  }

  @action
  async handleFieldValidation(e: Event): Promise<void> {
    const { target } = e;
    const { name } = target as HTMLInputElement;

    if (name) {
      const field = this.fields.get(name as FormKey<FormData<DATA>>);

      if (field) {
        this.lastValidationResult = await this.validate();
        field.validationEnabled = true;
      }
    } else {
      // @todo how to handle custom controls that don't emit focusout/change events from native form controls?
    }
  }

  @action
  async handleFieldRevalidation(e: Event): Promise<void> {
    const { target } = e;
    const { name } = target as HTMLInputElement;

    if (name) {
      if (this.showErrorsFor(name as FormKey<FormData<DATA>>)) {
        this.lastValidationResult = await this.validate();
        // field.validationEnabled = true;
      }
    } else {
      // @todo how to handle custom controls that don't emit focusout/change events from native form controls?
    }
  }
}
