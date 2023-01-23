import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { action } from '@ember/object';

import CheckboxComponent from './control/checkbox';
import InputComponent from './control/input';
import RadioComponent from './control/radio';
import TextareaComponent from './control/textarea';
import LabelComponent from './label';

import type { HeadlessFormData, ValidationError } from '../headless-form';
import type { HeadlessFormControlCheckboxComponentSignature } from './control/checkbox';
import type { HeadlessFormControlInputComponentSignature } from './control/input';
import type { HeadlessFormControlRadioComponentSignature } from './control/radio';
import type { HeadlessFormControlTextareaComponentSignature } from './control/textarea';
import type { HeadlessFormLabelComponentSignature } from './label';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

export type FieldValidateCallback<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> = (
  fieldValue: DATA[KEY],
  fieldName: KEY,
  formData: DATA
) =>
  | true
  | ValidationError<DATA[KEY]>[]
  | Promise<true | ValidationError<DATA[KEY]>[]>;

export interface HeadlessFormFieldComponentSignature<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> {
  Args: {
    data: DATA;
    name: KEY;
    set: (key: KEY, value: DATA[KEY]) => void;
    validate?: FieldValidateCallback<DATA, KEY>;
  };
  Blocks: {
    default: [
      {
        label: WithBoundArgs<typeof LabelComponent, 'fieldId'>;
        input: WithBoundArgs<
          typeof InputComponent,
          'fieldId' | 'value' | 'setValue'
        >;
        checkbox: WithBoundArgs<
          typeof CheckboxComponent,
          'fieldId' | 'value' | 'setValue'
        >;
        radio: WithBoundArgs<typeof RadioComponent, 'selected' | 'setValue'>;
        textarea: WithBoundArgs<
          typeof TextareaComponent,
          'fieldId' | 'value' | 'setValue'
        >;
        value: DATA[KEY];
        id: string;
        setValue: (value: DATA[KEY]) => void;
        errors: ValidationError<DATA[KEY]>[];
      }
    ];
  };
}

export default class HeadlessFormFieldComponent<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> extends Component<HeadlessFormFieldComponentSignature<DATA, KEY>> {
  LabelComponent: ComponentLike<HeadlessFormLabelComponentSignature> =
    LabelComponent;
  InputComponent: ComponentLike<HeadlessFormControlInputComponentSignature> =
    InputComponent;
  CheckboxComponent: ComponentLike<HeadlessFormControlCheckboxComponentSignature> =
    CheckboxComponent;
  TextareaComponent: ComponentLike<HeadlessFormControlTextareaComponentSignature> =
    TextareaComponent;
  RadioComponent: ComponentLike<HeadlessFormControlRadioComponentSignature> =
    RadioComponent;

  get value(): DATA[KEY] {
    return this.args.data[this.args.name];
  }

  get errors(): ValidationError<DATA[KEY]>[] {
    return [];
  }

  get valueAsString(): string | undefined {
    assert(
      `Only string values are expected for ${String(
        this.args.name
      )}, but you passed ${typeof this.value}`,
      typeof this.value === 'undefined' || typeof this.value === 'string'
    );

    return this.value;
  }

  get valueAsBoolean(): boolean | undefined {
    assert(
      `Only boolean values are expected for ${String(
        this.args.name
      )}, but you passed ${typeof this.value}`,
      typeof this.value === 'undefined' || typeof this.value === 'boolean'
    );

    return this.value;
  }

  @action
  setValue(value: unknown): void {
    this.args.set(this.args.name, value as DATA[KEY]);
  }
}
