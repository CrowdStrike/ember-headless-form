import Component from '@glimmer/component';

import InputComponent from './control/input';
import CheckboxComponent from './control/checkbox';
import LabelComponent from './field/label';

import type { HeadlessFormData } from '../headless-form';
import type { HeadlessFormControlInputComponentSignature } from './control/input';
import type { HeadlessFormControlCheckboxComponentSignature } from './control/checkbox';
import type { HeadlessFormFieldLabelComponentSignature } from './field/label';
import type { ComponentLike, WithBoundArgs } from '@glint/template';
import { assert } from '@ember/debug';
import { action } from '@ember/object';

export interface HeadlessFormFieldComponentSignature<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> {
  Args: {
    data: DATA;
    name: KEY;
    set: (key: KEY, value: DATA[KEY]) => void;
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
        value: DATA[KEY];
        id: string;
        setValue: (value: DATA[KEY]) => void;
      }
    ];
  };
}

export default class HeadlessFormFieldComponent<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> extends Component<HeadlessFormFieldComponentSignature<DATA, KEY>> {
  LabelComponent: ComponentLike<HeadlessFormFieldLabelComponentSignature> =
    LabelComponent;
  InputComponent: ComponentLike<HeadlessFormControlInputComponentSignature> =
    InputComponent;
  CheckboxComponent: ComponentLike<HeadlessFormControlCheckboxComponentSignature> =
    CheckboxComponent;

  get value(): DATA[KEY] {
    return this.args.data[this.args.name];
  }

  get valueAsString(): string {
    assert(
      `Only string values are expected for ${String(
        this.args.name
      )}, but you passed ${typeof this.value}`,
      typeof this.value === 'string'
    );

    return this.value;
  }

  get valueAsBoolean(): boolean {
    assert(
      `Only boolean values are expected for ${String(
        this.args.name
      )}, but you passed ${typeof this.value}`,
      typeof this.value === 'boolean'
    );

    return this.value;
  }

  @action
  setValue(value: unknown): void {
    this.args.set(this.args.name, value as DATA[KEY]);
  }
}
