import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { action } from '@ember/object';

import CheckboxComponent from './control/checkbox';
import InputComponent from './control/input';
import RadioComponent from './control/radio';
import TextareaComponent from './control/textarea';
import ErrorsComponent from './errors';
import LabelComponent from './label';

import type { HeadlessFormControlCheckboxComponentSignature } from './control/checkbox';
import type { HeadlessFormControlInputComponentSignature } from './control/input';
import type { HeadlessFormControlRadioComponentSignature } from './control/radio';
import type { HeadlessFormControlTextareaComponentSignature } from './control/textarea';
import type { HeadlessFormErrorsComponentSignature } from './errors';
import type { HeadlessFormLabelComponentSignature } from './label';
import type {
  ErrorRecord,
  FieldValidateCallback,
  FormData,
  RegisterFieldCallback,
  UnregisterFieldCallback,
} from './types';
import type { FormKey, UserData, ValidationError } from './types';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

export interface HeadlessFormFieldComponentSignature<
  DATA extends UserData,
  KEY extends FormKey<FormData<DATA>> = FormKey<FormData<DATA>>
> {
  Args: {
    data: FormData<DATA>;
    name: KEY;
    set: (key: KEY, value: DATA[KEY]) => void;
    validate?: FieldValidateCallback<FormData<DATA>, KEY>;
    errors?: ErrorRecord<DATA, KEY>;
    registerField: RegisterFieldCallback<FormData<DATA>, KEY>;
    unregisterField: UnregisterFieldCallback<FormData<DATA>, KEY>;
    triggerValidationFor(name: string): Promise<void>;
  };
  Blocks: {
    default: [
      {
        label: WithBoundArgs<typeof LabelComponent, 'fieldId'>;
        input: WithBoundArgs<
          typeof InputComponent,
          'name' | 'fieldId' | 'value' | 'setValue' | 'invalid' | 'errorId'
        >;
        checkbox: WithBoundArgs<
          typeof CheckboxComponent,
          'name' | 'fieldId' | 'value' | 'setValue' | 'invalid' | 'errorId'
        >;
        radio: WithBoundArgs<
          typeof RadioComponent,
          'name' | 'selected' | 'setValue'
        >;
        textarea: WithBoundArgs<
          typeof TextareaComponent,
          'name' | 'fieldId' | 'value' | 'setValue' | 'invalid' | 'errorId'
        >;
        value: DATA[KEY];
        id: string;
        setValue: (value: DATA[KEY]) => void;
        errors?: WithBoundArgs<
          typeof ErrorsComponent<DATA[KEY]>,
          'errors' | 'id'
        >;
        triggerValidation: () => void;
      }
    ];
  };
}

export default class HeadlessFormFieldComponent<
  DATA extends FormData,
  KEY extends FormKey<FormData<DATA>> = FormKey<FormData<DATA>>
> extends Component<HeadlessFormFieldComponentSignature<DATA, KEY>> {
  LabelComponent: ComponentLike<HeadlessFormLabelComponentSignature> =
    LabelComponent;
  InputComponent: ComponentLike<HeadlessFormControlInputComponentSignature> =
    InputComponent;
  CheckboxComponent: ComponentLike<HeadlessFormControlCheckboxComponentSignature> =
    CheckboxComponent;
  ErrorsComponent: ComponentLike<
    HeadlessFormErrorsComponentSignature<DATA[KEY]>
  > = ErrorsComponent;
  TextareaComponent: ComponentLike<HeadlessFormControlTextareaComponentSignature> =
    TextareaComponent;
  RadioComponent: ComponentLike<HeadlessFormControlRadioComponentSignature> =
    RadioComponent;

  constructor(
    owner: unknown,
    args: HeadlessFormFieldComponentSignature<DATA, KEY>['Args']
  ) {
    super(owner, args);

    this.args.registerField(this.args.name, {
      validate: this.args.validate,
    });
  }

  willDestroy(): void {
    this.args.unregisterField(this.args.name);

    super.willDestroy();
  }

  get value(): DATA[KEY] {
    return this.args.data[this.args.name];
  }

  get errors(): ValidationError<DATA[KEY]>[] | undefined {
    return this.args.errors?.[this.args.name];
  }

  get hasErrors(): boolean {
    return this.errors !== undefined;
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
