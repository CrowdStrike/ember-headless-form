import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { action } from '@ember/object';

// Possible values for the input type, see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#input_types
// for the sake ok completeness, we list all here, with some commented out that are better handled elsewhere, or not at all...
export type InputType =
  // | 'button' - not useful as a control component
  // | 'checkbox' - handled separately, for handling `checked` correctly and operating with true boolean values
  | 'color'
  | 'date'
  | 'datetime-local'
  | 'email'
  // | 'file' - would need special handling
  | 'hidden'
  // | 'image' - not useful as a control component
  | 'month'
  | 'number'
  | 'password'
  // | 'radio' - handled separately, for handling groups or radio buttons
  | 'range'
  // | 'reset' - would need special handling
  | 'search'
  // | 'submit' - not useful as a control component
  | 'tel'
  | 'text'
  | 'time'
  | 'url'
  | 'week';

export interface HeadlessFormControlInputComponentSignature<VALUE> {
  Element: HTMLInputElement;
  Args: {
    value: VALUE;
    type?: InputType;
    fieldId: string;
    setValue: (value: VALUE) => void;
  };
}

export default class HeadlessFormControlInputComponent<VALUE> extends Component<
  HeadlessFormControlInputComponentSignature<VALUE>
> {
  constructor(
    owner: unknown,
    args: HeadlessFormControlInputComponentSignature<VALUE>['Args']
  ) {
    assert(
      `input component does not support @type="${args.type}" as there is a dedicated component for this. Please use the \`field.${args.type}\` instead!`,
      args.type === undefined ||
        // TS would guard us against using an unsupported `InputType`, but for JS consumers we add a dev-only runtime check here
        (args.type as string) !== 'checkbox'
    );

    super(owner, args);
  }

  get type(): InputType {
    return this.args.type ?? 'text';
  }

  get valueAsString(): string {
    assert(
      `input can only handle string values, but you passed ${typeof this.args
        .value}`,
      typeof this.args.value === 'string'
    );

    return this.args.value;
  }

  @action
  handleInput(e: Event | InputEvent): void {
    this.args.setValue((e.target as HTMLInputElement).value as VALUE);
  }
}
