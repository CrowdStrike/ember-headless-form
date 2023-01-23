import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

import { TrackedObject } from 'tracked-built-ins';

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
) => true | ErrorRecord<DATA> | Promise<true | ErrorRecord<DATA>>;

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
          'data' | 'set' | 'errors'
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

  @tracked errors?: ErrorRecord<DATA>;

  get validateOn(): ValidateOn {
    return this.args.validateOn ?? 'submit';
  }

  get revalidateOn(): ValidateOn {
    return this.args.revalidateOn ?? 'change';
  }

  @action
  async onSubmit(e: Event): Promise<void> {
    e.preventDefault();

    if (this.args.validate) {
      const validationResult = await this.args.validate(this.internalData);

      if (validationResult !== true) {
        this.errors = validationResult;
      }
    }

    this.args.onSubmit?.(this.internalData);
  }

  @action
  set<KEY extends keyof DATA>(key: KEY, value: DATA[KEY]): void {
    this.internalData[key] = value;
  }
}
