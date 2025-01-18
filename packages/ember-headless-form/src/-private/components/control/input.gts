import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { on } from '@ember/modifier';
import { action } from '@ember/object';

import NumberParser from 'intl-number-parser';

// Possible values for the input type, see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#input_types
// for the sake of completeness, we list all here, with some commented out that are better handled elsewhere, or not at all...
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

export interface HeadlessFormControlInputComponentSignature {
  Element: HTMLInputElement;
  Args: {
    /**
     * The `type` of the `<input>` element, by default `text`.
     *
     * Note that certain types should not be used, as they have dedicated control components:
     * - `checkbox`
     * - `radio`
     *
     * Also these types are not useful to use as input controls:
     * - `button`
     * - `file`
     * - `image`
     * - `reset`
     * - `submit`
     *
     * @see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#input_types
     */
    type?: InputType;

    /**
     * Some inputs are specific to locales, like numbers.
     * Ex:
     * "en-us"
     * If this ends up being undefined it will simply use the locale of the user.
     *
     * ? While the linked resource below mentions you can pass in a Intl.Locale object, the current library we use for this doesn't
     * ? support it. So stick with strings using a BCP 47 language tag.
     *
     * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat/NumberFormat#locales
     * @see https://datatracker.ietf.org/doc/html/rfc4647
     */
    locale?: string

    /**
     * Adding the ability to add additional options for the formatter. This currently only applies to number types.
     * Ex:
     * { style: 'currency', currency: 'EUR' }
     *
     * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat
     */
    formatOptions?: Intl.NumberFormatOptions,

    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    value: string | number;

    /*
     * @internal
     */
    name: string;

    /*
     * @internal
     */
    fieldId: string;

    /*
     * @internal
     */
    setValue: (value: string | number) => void;

    /*
     * @internal
     */
    invalid: boolean;

    /*
     * @internal
     */
    errorId: string;
  };
}

export default class HeadlessFormControlInputComponent extends Component<HeadlessFormControlInputComponentSignature> {
  public formatter: NumberParser;

  constructor(
    owner: unknown,
    args: HeadlessFormControlInputComponentSignature['Args']
  ) {
    assert(
      `input component does not support @type="${args.type}" as there is a dedicated component for this. Please use the \`field.${args.type}\` instead!`,
      args.type === undefined ||
        // TS would guard us against using an unsupported `InputType`, but for JS consumers we add a dev-only runtime check here
        !['checkbox', 'radio'].includes(args.type as string)
    );
    super(owner, args);

    this.formatter = NumberParser(this.locale, this.formatOptions);
  }

  get type(): InputType {
    return this.args.type ?? 'text';
  }

  get locale(): String {
    return this.args.locale;
  }

  get formatOptions(): Object {
    return this.args.formatOptions ?? {};
  }

  @action
  handleInput(e: Event | InputEvent): void {
    assert('Expected HTMLInputElement', e.target instanceof HTMLInputElement);
    this.args.setValue(e.target.value);
  }

  @action
  handleUnfocus(e: Event | InputEvent): void {
    assert('Expected HTMLInputElement', e.target instanceof HTMLInputElement);

    if(this.type === "number"){
      this.args.setValue(this.formatter(e.target.value));
    }
  }

  <template>
    <input
      name={{@name}}
      type={{@type}}
      value={{@value}}
      id={{@fieldId}}
      aria-invalid={{if @invalid "true"}}
      aria-describedby={{if @invalid @errorId}}
      ...attributes
      {{on "input" this.handleInput}}
      {{on "focusout" this.handleUnfocus}}
    />
  </template>
}
