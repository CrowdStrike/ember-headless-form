import Component from '@glimmer/component';
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

export type FormValidateCallback<DATA extends HeadlessFormData> = (
  formData: DATA
) =>
  | true
  | Record<keyof DATA, ValidationError[]>
  | Promise<true | Record<keyof DATA, ValidationError[]>>;

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
        field: WithBoundArgs<typeof FieldComponent<DATA>, 'data' | 'set'>;
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

  get validateOn(): ValidateOn {
    return this.args.validateOn ?? 'submit';
  }

  get revalidateOn(): ValidateOn {
    return this.args.revalidateOn ?? 'change';
  }

  @action
  onSubmit(e: Event): void {
    e.preventDefault();

    this.args.onSubmit?.(this.internalData);
  }

  @action
  set<KEY extends keyof DATA>(key: KEY, value: DATA[KEY]): void {
    this.internalData[key] = value;
  }
}
