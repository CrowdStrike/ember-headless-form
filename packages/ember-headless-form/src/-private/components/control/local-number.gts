import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { action }from '@ember/object';

import NumberParser from 'intl-number-parser';

/**
 *  This component works to solve using localized number inputs and will render a text field to support it as
 *  a normal number input field only supports "." as a decimal separator no matter the locale. It will format
 *  the numbers correctly when input is completed or it is focused off. When data is presented, it is formatted
 *  into the expected decimal value for data storage. Ex, a German user may type 1.234,56 but this data should be
 *  saved in the database as 1234.56, so that is what will be presented as the data to the form. If you want this
 *  behavior to be overriden, you can set the dataFormatting option (boolean) to true.
 */

export interface HeadlessFormControlLocalNumberInputComponentSignature {
  Element: HTMLInputElement;
  Args: {
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
    formatOptions?: object,

    /**
     * Determines whether or not the actual value is converted to decmials. Ex: German 1.234,56 is converted to 1234.56 float or
     * if
     */
    dataFormatting: boolean;

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
  }
}


export default class HeadlessFormControlLocalNumberInputComponent extends Component<HeadlessFormControlLocalNumberInputComponentSignature>{
    public formatter: NumberParser;

    /**
     *  What will be displayed to the user, in their locale.
     */
    public displayed?: string;

    constructor(
      owner: unknown,
      args: HeadlessFormControlLocalNumberInputComponentSignature['Args']
    ){
      super(owner, args);

      this.formatter = NumberParser(this.locale, this.formatOptions);
    }

    get locale(): String {
      return this.args.locale ?? navigator.language;
    }

    get formatOptions(): Object {
      return this.args.formatOptions ?? {};
    }

    get displayedValue(): string{
      return this.displayed;
    }

    @action
    handleFormatting(e: Event | InputEvent): void{
      this.args.setValue(this.formatter(e.target.value));
    }

    <template>
      <input
        name={{@name}}
        type="text"
        value={{this.displayed}}
        id={{@fieldId}}
        aria-invalid={{if @invalid "true"}}
        aria-describedBy={{if @invalid @errorId}}
        ...attributes
        {{on "focusout" this.handleFormatting }}
      />
    </template>
}

