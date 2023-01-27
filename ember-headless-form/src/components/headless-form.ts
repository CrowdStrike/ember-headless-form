import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { assert } from '@ember/debug';
import { action } from '@ember/object';

import { TrackedObject } from 'tracked-built-ins';

import FieldComponent from './-private/field';

import type { HeadlessFormFieldComponentSignature } from './-private/field';
import type {
  ErrorRecord,
  FieldData,
  FormData,
  FormKey,
  FormValidateCallback,
  UserData,
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
          typeof FieldComponent<FormData<DATA>>,
          'data' | 'set' | 'errors' | 'registerField' | 'unregisterField'
        >;
      }
    ];
  };
}

export default class HeadlessFormComponent<
  DATA extends UserData
> extends Component<HeadlessFormComponentSignature<DATA>> {
  FieldComponent: ComponentLike<HeadlessFormFieldComponentSignature<DATA>> =
    FieldComponent;

  internalData: FormData<DATA> = new TrackedObject(
    this.args.data ?? {}
  ) as FormData<DATA>;

  fields = new Map<FormKey<FormData<DATA>>, FieldData<FormData<DATA>>>();

  @tracked lastValidationResult?: ErrorRecord<FormData<DATA>>;

  get validateOn(): ValidateOn {
    return this.args.validateOn ?? 'submit';
  }

  get revalidateOn(): ValidateOn {
    return this.args.revalidateOn ?? 'change';
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

  @action
  async onSubmit(e: Event): Promise<void> {
    e.preventDefault();

    this.lastValidationResult = await this.validate();

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
    field: FieldData<FormData<DATA>>
  ): void {
    assert(
      `You passed @name="${String(
        name
      )}" to the form field, but this is already in use. Names of form fields must be unique!`,
      !this.fields.has(name)
    );
    this.fields.set(name, field);
  }

  @action
  unregisterField(name: FormKey<FormData<DATA>>): void {
    this.fields.delete(name);
  }

  @action
  set<KEY extends FormKey<FormData<DATA>>>(key: KEY, value: DATA[KEY]): void {
    this.internalData[key] = value;
  }
}
