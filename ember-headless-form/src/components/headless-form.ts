import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

import { TrackedMap, TrackedObject } from 'tracked-built-ins';

import FieldComponent from './-private/field';

import type { HeadlessFormFieldComponentSignature } from './-private/field';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

export type HeadlessFormData = object;
export type ValidateOn = 'change' | 'blur' | 'submit';

export interface ValidationError<T = unknown> {
  type: string;
  value: T;
  message?: string;
}

export type ErrorRecord<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> = Partial<Record<KEY, ValidationError<DATA[KEY]>[]>>;

export type FormValidateCallback<DATA extends HeadlessFormData> = (
  formData: DATA
) => undefined | ErrorRecord<DATA> | Promise<undefined | ErrorRecord<DATA>>;

export type FieldValidateCallback<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> = (
  fieldValue: DATA[KEY],
  fieldName: KEY,
  formData: DATA
) =>
  | undefined
  | ValidationError<DATA[KEY]>[]
  | Promise<undefined | ValidationError<DATA[KEY]>[]>;

export interface FieldData<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> {
  validate?: FieldValidateCallback<DATA, KEY>;
}

export type RegisterFieldCallback<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> = (name: KEY, field: FieldData<DATA, KEY>) => void;

export type UnregisterFieldCallback<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> = (name: KEY) => void;

export interface HeadlessFormComponentSignature<DATA extends HeadlessFormData> {
  Element: HTMLFormElement;
  Args: {
    data?: DATA;
    validateOn?: ValidateOn;
    revalidateOn?: ValidateOn;
    validate?: FormValidateCallback<DATA>;
    onSubmit?: (data: DATA) => void;
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

export default class HeadlessFormComponent<
  DATA extends HeadlessFormData
> extends Component<HeadlessFormComponentSignature<DATA>> {
  FieldComponent: ComponentLike<HeadlessFormFieldComponentSignature<DATA>> =
    FieldComponent;

  internalData: DATA = new TrackedObject(this.args.data ?? {}) as DATA;

  fields = new TrackedMap<keyof DATA, FieldData<DATA>>();

  @tracked errors?: ErrorRecord<DATA>;

  get validateOn(): ValidateOn {
    return this.args.validateOn ?? 'submit';
  }

  get revalidateOn(): ValidateOn {
    return this.args.revalidateOn ?? 'change';
  }

  async validate(): Promise<ErrorRecord<DATA> | undefined> {
    let errors: ErrorRecord<DATA> | undefined = undefined;

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

    const validationResult = await this.validate();

    if (validationResult) {
      this.errors = validationResult;
    }

    // @todo only when valid
    this.args.onSubmit?.(this.internalData);
  }

  @action
  registerField(name: keyof DATA, field: FieldData<DATA>): void {
    this.fields.set(name, field);
  }

  @action
  unregisterField(name: keyof DATA): void {
    this.fields.delete(name);
  }

  @action
  set<KEY extends keyof DATA>(key: KEY, value: DATA[KEY]): void {
    this.internalData[key] = value;
  }
}
