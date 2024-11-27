import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { fn, hash } from '@ember/helper';
import { action, get } from '@ember/object';

import CaptureEventsModifier from '../modifiers/capture-events';
import { uniqueId } from '../utils';
import CheckboxComponent from './control/checkbox';
import CheckboxGroupComponent from './control/checkbox-group';
import InputComponent from './control/input';
import RadioGroupComponent from './control/radio-group';
import SelectComponent from './control/select';
import TextareaComponent from './control/textarea';
import ErrorsComponent from './errors';
import LabelComponent from './label';

import type { CaptureEventsModifierSignature } from '../modifiers/capture-events';
import type {
  ErrorRecord,
  FieldValidateCallback,
  FormData,
  FormKey,
  RegisterFieldCallback,
  UnregisterFieldCallback,
  UserData,
  ValidationError,
} from '../types';
import type { ModifierLike, WithBoundArgs } from '@glint/template';

export interface HeadlessFormFieldComponentSignature<
  DATA extends UserData,
  KEY extends FormKey<FormData<DATA>> = FormKey<FormData<DATA>>
> {
  Args: {
    /**
     * The name of your field, which must match a property of the `@data` passed to the form
     */
    name: KEY;

    /**
     * Provide a custom validation function, that operates only on this specific field. Eventual validation errors are merged with native validation errors to determine the effective set of errors rendered for the field.
     *
     * Return undefined when no validation errors are present, otherwise an array of (one or multiple) `ValidationError`s.
     */
    validate?: FieldValidateCallback<FormData<DATA>, KEY>;

    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    data: FormData<DATA>;

    /*
     * @internal
     */
    set: (key: KEY, value: DATA[KEY]) => void;

    /*
     * @internal
     */
    errors?: ErrorRecord<DATA, KEY>;

    /*
     * @internal
     */
    registerField: RegisterFieldCallback<FormData<DATA>, KEY>;

    /*
     * @internal
     */
    unregisterField: UnregisterFieldCallback<FormData<DATA>, KEY>;

    /*
     * @internal
     */
    triggerValidationFor(name: KEY): Promise<void>;

    /*
     * @internal
     */
    fieldValidationEvent: 'focusout' | 'change' | 'input' | undefined;

    /*
     * @internal
     */
    fieldRevalidationEvent: 'focusout' | 'change' | 'input' | undefined;
  };
  Blocks: {
    default: [
      {
        /**
         * Yielded component that renders the `<label>` element.
         */
        Label: WithBoundArgs<typeof LabelComponent, 'fieldId'>;

        /**
         * Yielded control component that renders an `<input>` element.
         */
        Input: WithBoundArgs<
          typeof InputComponent,
          'name' | 'fieldId' | 'value' | 'setValue' | 'invalid' | 'errorId'
        >;

        /**
         * Yielded control component that renders an `<input type="checkbox">` element.
         */
        Checkbox: WithBoundArgs<
          typeof CheckboxComponent,
          'name' | 'fieldId' | 'value' | 'setValue' | 'invalid' | 'errorId'
        >;

        /**
         * Yielded control component that renders a single radio control.
         *
         * Use multiple to define a radio group. It further yields components to render `Input` and `Label`.
         */
        RadioGroup: WithBoundArgs<
          typeof RadioGroupComponent,
          'name' | 'selected' | 'setValue' | 'invalid' | 'errorId'
        >;

        /**
         * Yielded control component that renders a single checkbox control.
         *
         * Use multiple to define a checkbox group. It further yields components to render `Input` and `Label`.
         */
        CheckboxGroup: WithBoundArgs<
          typeof CheckboxGroupComponent,
          'name' | 'selected' | 'setValue' | 'invalid' | 'errorId'
        >;

        /**
         * Yielded control component that renders a `<select>` element.
         */
        Select: WithBoundArgs<
          typeof SelectComponent,
          'name' | 'fieldId' | 'value' | 'setValue' | 'invalid' | 'errorId'
        >;

        /**
         * Yielded control component that renders a `<textarea>` element.
         */
        Textarea: WithBoundArgs<
          typeof TextareaComponent,
          'name' | 'fieldId' | 'value' | 'setValue' | 'invalid' | 'errorId'
        >;

        /**
         * The current value of the field's form data.
         *
         * If you don't use one of the supplied control components, then use this to pass the value to your custom component.
         */
        value: DATA[KEY];

        /**
         * Action to update the (internal) form data for this field.
         *
         * If you don't use one of the supplied control components, then use this to update the value whenever your custom component's value has changed.
         */
        setValue: (value: DATA[KEY]) => void;

        /**
         * Unique ID of this field, used to associate the control with its label.
         *
         * If you don't use the supplied components, then you can use this as the `id` of the control and the `for` attribute of the `<label>`.
         */
        id: string;

        /**
         * Unique error ID of this field, used to associate the control with its validation error message.
         *
         * If you don't use the supplied components, then you can use this as the `id` of the validation error element and the `aria-errormessage` or `aria-describedby` attribute of the control.
         */
        errorId: string;

        /**
         * Yielded component that renders all validation error messages if there are any.
         *
         * In non-block mode it will render all messages by default. In block-mode, it yields all `ValidationError` objects for you to customize the rendering.
         */
        Errors?: WithBoundArgs<
          typeof ErrorsComponent<DATA[KEY]>,
          'errors' | 'id'
        >;

        /**
         * Will be `true` when validation was triggered and this field is invalid.
         *
         * You can use this to customize your markup, e.g. apply HTML classes for error styling.
         */
        isInvalid: boolean;

        /**
         * An array of raw ValidationError objects, for custom rendering of error output
         */
        rawErrors?: ValidationError<DATA[KEY]>[];

        /**
         * When calling this action, validation will be triggered.
         *
         * Can be used for custom controls that don't emit the `@validateOn` events that would normally trigger a dynamic validation.
         */
        triggerValidation: () => void;

        /**
         * Yielded modifier that when applied to the control element or any other element wrapping it will be able to recognize the `@validateOn` events and associate them to this field.
         *
         * This is only needed for very special cases, where the control is not a native form control or does not have the `@name` of the field assigned to the `name` attribute of the control.
         */
        captureEvents: WithBoundArgs<
          ModifierLike<CaptureEventsModifierSignature>,
          'event' | 'triggerValidation'
        >;
      }
    ];
  };
}

export default class HeadlessFormFieldComponent<
  DATA extends FormData,
  KEY extends FormKey<FormData<DATA>> = FormKey<FormData<DATA>>
> extends Component<HeadlessFormFieldComponentSignature<DATA, KEY>> {
  LabelComponent = LabelComponent;
  InputComponent = InputComponent;
  CheckboxComponent = CheckboxComponent;
  ErrorsComponent = ErrorsComponent<DATA[KEY]>;
  SelectComponent = SelectComponent;
  TextareaComponent = TextareaComponent;
  RadioGroupComponent = RadioGroupComponent;
  CheckboxGroupComponent = CheckboxGroupComponent;
  CaptureEventsModifier = CaptureEventsModifier;

  constructor(
    owner: unknown,
    args: HeadlessFormFieldComponentSignature<DATA, KEY>['Args']
  ) {
    super(owner, args);

    assert(
      'Nested property paths in @name are not supported.',
      typeof this.args.name !== 'string' || !this.args.name.includes('.')
    );

    this.args.registerField(this.args.name, {
      validate: this.args.validate,
    });
  }

  willDestroy(): void {
    this.args.unregisterField(this.args.name);

    super.willDestroy();
  }

  get value(): DATA[KEY] {
    // when @mutableData is set, data is something we don't control, i.e. might require old-school get() to be on the safe side
    // we do not want to support nested property paths for now though, see the constructor assertion!
    return get(this.args.data, this.args.name) as DATA[KEY];
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

  get valueAllAsString(): string[] {
    assert(
      `Only string values are expected for ${String(
        this.args.name
      )}`,
      typeof this.value === 'undefined' ||
        (Array.isArray(this.value) &&
          this.value.every((v) => typeof v === 'string'))
    );

    return this.value ?? [];
  }

  get valueAsStringOrNumber(): string | number | undefined {
    assert(
      `Only string or number values are expected for ${String(
        this.args.name
      )}, but you passed ${typeof this.value}`,
      typeof this.value === 'undefined' ||
        typeof this.value === 'string' ||
        typeof this.value === 'number'
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

  <template>
    {{#let
      (uniqueId)
      (uniqueId)
      (fn @set @name)
      (fn @triggerValidationFor @name)
      as |fieldId errorId setValue triggerValidation|
    }}
      {{yield
        (hash
          Label=(component this.LabelComponent fieldId=fieldId)
          Input=(component
            this.InputComponent
            name=@name
            fieldId=fieldId
            errorId=errorId
            value=this.valueAsStringOrNumber
            setValue=this.setValue
            invalid=this.hasErrors
          )
          Checkbox=(component
            this.CheckboxComponent
            name=@name
            fieldId=fieldId
            errorId=errorId
            value=this.valueAsBoolean
            setValue=this.setValue
            invalid=this.hasErrors
          )
          Select=(component
            this.SelectComponent
            name=@name
            fieldId=fieldId
            errorId=errorId
            value=this.valueAsString
            setValue=this.setValue
            invalid=this.hasErrors
          )
          Textarea=(component
            this.TextareaComponent
            name=@name
            fieldId=fieldId
            errorId=errorId
            value=this.valueAsString
            setValue=this.setValue
            invalid=this.hasErrors
          )
          RadioGroup=(component
            this.RadioGroupComponent
            name=@name
            errorId=errorId
            selected=this.valueAsString
            setValue=this.setValue
            invalid=this.hasErrors
          )
          CheckboxGroup=(component
            this.CheckboxGroupComponent
            name=@name
            errorId=errorId
            selected=this.valueAllAsString
            setValue=this.setValue
            invalid=this.hasErrors
          )
          value=this.value
          setValue=setValue
          id=fieldId
          errorId=errorId
          Errors=(if
            this.errors
            (component this.ErrorsComponent errors=this.errors id=errorId)
          )
          isInvalid=this.hasErrors
          rawErrors=this.errors
          triggerValidation=triggerValidation
          captureEvents=(modifier
            this.CaptureEventsModifier
            event=(if
              this.hasErrors @fieldRevalidationEvent @fieldValidationEvent
            )
            triggerValidation=triggerValidation
          )
        )
      }}
    {{/let}}
  </template>
}
