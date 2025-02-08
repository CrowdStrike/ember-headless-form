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
     * Determines whether or not the actual value is converted to decimals when setting the data. Ex: German 1.234,56 is converted to 1234.56 float or
     * if you would prefer to have the formatted number be set to the data rather than the formatted number.
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
    // Formatter that will be used to convert locale to save-able value.
    public formatter: NumberParser;
    // Formatter that will be used to convert numbers to locale.
    public toFormatter: Intl.NumberFormat;

    private pastVal = "";

    constructor(
      owner: unknown,
      args: HeadlessFormControlLocalNumberInputComponentSignature['Args']
    ){
      super(owner, args);

      // Formatter from localized number to something we can use or store programmatically.
      this.formatter = NumberParser(this.locale, this.formatOptions);
      // Formatter to programmatic number to local number.
      this.toFormatter = new Intl.NumberFormat(this.locale, this.formatOptions);
    }

    get locale(): String {
      return this.args.locale ?? navigator.language;
    }

    /*
      Different languages define their zeros differently. For example, arabic uses "٠" while english will use "0".
      We need to know what their zero is in order to know when to programmatically run the formatter.
    */
    get zero(): String {
      return this.toFormatter.formatToParts(0)[0].value;
    }

    get formatOptions(): Object {
      return this.args.formatOptions ?? {};
    }

    get thousandSeparator(): string {
      return this.toFormatter.formatToParts(1000).find(part => part.type === 'group').value;
    }

    get decimalSeparator(): string {
      return this.toFormatter.formatToParts(0.01).find(part => part.type === 'decimal').value;
    }

    get displayed(): string {
      return this.toFormatter.format(this.args.value);
    }

    /*
    * Set the user's input to a position on a text box.
    */
    private setCaretPos(elem, caretPos){
      if(elem != null){
        if(elem.createTextRange) {
            let range = elem.createTextRange();

            range.move('character', caretPos);
            range.select();
        }
        else {
            if(elem.selectionStart) {
                elem.focus();
                elem.setSelectionRange(caretPos, caretPos);
            }
            else
                elem.focus();
        }
      }
    }

    @action
    handleFormatting(e: Event | InputEvent): void {
      // Get the curser position.
      let caretPos:number = e.target.selectionStart ?? 0;

      // Allow for empty
      if(e.target.value === ""){
        this.args.setValue("");

        return;
      }

      // If there's more than 1 decimal separator, ignore the input and return to what the value was previously.
      // There will never be more than one decimal separator. We will also do this if the user's input results in NaN.
      if((e.target.value.split(this.decimalSeparator).length > 2 || isNaN(this.formatter(e.target.value)))){
        e.target.value = this.pastVal;

        return;
      }

      // Determine where the decimal point is.
      let decimalPos = e.target.value.indexOf(this.decimalSeparator);

      // If the input ends with the decimal separator, thousand separator, or a zero that is inputted beyond the decimal let them cook. (don't touch the formatting)
      if((e.target.value.endsWith(this.decimalSeparator)) || (e.target.value.endsWith(this.thousandSeparator)) || (e.target.value.endsWith(this.zero) && caretPos > decimalPos && decimalPos >= 0)){
        return;
      }

      /*
      Gracefully handle the removal of a thousand separator. Count the number of thousand separators present in
      current value. If there are less than before and a thousand separator was present in the place the
      caret's current position, remove the value that was just before the caret, then continue to formatting.
      */
      if((e.target.value.split(this.thousandSeparator).length < this.pastVal.split(this.thousandSeparator).length) && this.pastVal[caretPos] == this.thousandSeparator){
        e.target.value = e.target.value.substring(0, caretPos-1)+e.target.value.substring(caretPos);
        caretPos = caretPos - (this.pastVal.split(this.thousandSeparator).length - e.target.value.split(this.thousandSeparator).length);
      }

      e.target.value = this.toFormatter.format(this.formatter(e.target.value));

      /*
      If after formatting, we now have more thousand separators, shift the caret forward the difference.
      (Say we go from 2 separators to 3, we move the caret forward 1.)
      */
      if((e.target.value.split(this.thousandSeparator).length > this.pastVal.split(this.thousandSeparator).length)){
          caretPos = caretPos + (e.target.value.split(this.thousandSeparator).length - this.pastVal.split(this.thousandSeparator).length);
      }

      // Set the data as preferred.
      this.args.setValue(this.args.dataFormatting ? e.target.value : this.formatter(e.target.value));

      this.pastVal = e.target.value;

      this.setCaretPos(e.target, caretPos);
    }

    <template>
      <input
        name={{@name}}
        type="text"
        id={{@fieldId}}
        aria-invalid={{if @invalid "true"}}
        aria-describedBy={{if @invalid @errorId}}
        ...attributes
        {{on "input" this.handleFormatting }}
      />
    </template>
}

