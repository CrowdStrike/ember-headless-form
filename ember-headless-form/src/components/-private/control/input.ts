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
