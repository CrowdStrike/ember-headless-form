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

    private pastVal = "0";

    constructor(
      owner: unknown,
      args: HeadlessFormControlLocalNumberInputComponentSignature['Args']
    ){
      super(owner, args);

      // Formatter from localized number to something we can use or store programmatically.
      this.formatter = NumberParser(this.locale, this.formatOptions);

      // Formatter to programmatic number to local number.
      this.toFormatter = new Intl.NumberFormat(this.locale, this.formatOptions);

      if(this.args.value){
        this.pastVal = this.args.value;
      }
    }

    get locale(): String {
      return this.args.locale ?? navigator.language ?? "en-US";
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

    get resolvedOptions(): Object {
      return this.toFormatter.resolvedOptions();
    }

    get thousandSeparator(): string {
      return this.toFormatter.formatToParts(1000).find(part => part.type === 'group').value;
    }

    get decimalSeparator(): string {
      return this.toFormatter.formatToParts(0.01).find(part => part.type === 'decimal').value;
    }

    get displayed(): string {
        return this.toFormatter.format(this.args.value ?? 0);
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

    /**
     * Get only non-numbers.
     */
    private getNonNumbers(value:string):Array{
      return this.toFormatter.formatToParts(this.formatter(value)).filter((item) => {
        return ["integer", "fraction"].indexOf(item.type) == -1;
      });
    }

    /**
     * Return the number formatted corrected
     */
    private parseDisplay(value:string):String {
      return this.toFormatter.format(this.formatter(value));
    }

    @action
    handleInput(e: Event | InputEvent): void {
      // Get the curser position.
      let caretPos:number = e.target.selectionStart ?? 0;
      // Determine where the decimal point is.
      const decimalPos:number = e.target.value.indexOf(this.decimalSeparator);

      // Allow for empty. Don't return if it ends with a decimal separator or the input is beyond the decimal.
      if(e.target.value === "" || this.formatter(e.target.value) == "0" && !e.target.value.endsWith(this.decimalSeparator) && !(caretPos > decimalPos)){
        this.args.setValue("0");
        this.pastValue = this.toFormatter.format("0");

        return;
      }

      /*
        If the input ends with the decimal separator (not more than one), or a zero that is inputted beyond the decimal let them cook. (don't touch the formatting)
      */
      if((e.target.value.endsWith(this.decimalSeparator) && !(e.target.value.split(this.decimalSeparator).length > 2)) || (e.target.value.endsWith(this.zero) && caretPos > decimalPos && decimalPos >= 0) && !(e.target.value.split(this.decimalSeparator).length > 2)){
        return;
      }

      /*
        Ignoring Inputs:
        If there's more than 1 decimal separator, a thousand separator beyond the decimal, or the input formatted results in NaN:
        ignore the input and return to what the value was previously.
        If the user tries to remove the one decimal separator, just jump them to it. Don't allow for removal.
        We cannot have a thousand separator beyond the decimal
        Move the input to the decimal place.
      */
      if(e.target.value.split(this.decimalSeparator).length > 2 || (decimalPos < e.target.value.lastIndexOf(this.thousandSeparator) && decimalPos != -1) || isNaN(this.formatter(e.target.value))){
        // Move curser to decimal if the user tries to input two.
        if(e.target.value.split(this.decimalSeparator).length > 2){
          caretPos = this.pastVal.indexOf(this.decimalSeparator)+1;
        }

        e.target.value = this.pastVal;
      }


      /*
        If inputting beyond the decimal position, begin inserting numbers in reverse. Ex, if the current textbox formatted as dollars is $0.00 and
        we as the user go to type 0.001 as the input, it should be shifted into 0.01. Then if we go to type 0.012 it should be shifted to 0.12 to
        the maximum number of decimals allowed by whatever format we are currently using. A sort of reverse insertion to the point of hitting the max
        number of decimals. However, if say the user has $0.20 in the input, we should allow for input between the 2 and the 0 to turn it into say, $0.21,
        pushing out the .
      */
      if(decimalPos < caretPos && decimalPos !== -1 && caretPos == e.target.value.length){
        if(e.target.value.split(this.decimalSeparator)[1].length > this.resolvedOptions.maximumFractionDigits ?? 0){

          let [pre,post] = e.target.value.split(this.decimalSeparator);

          pre = pre+post.substr(0,post.length-this.resolvedOptions.maximumFractionDigits);
          post = post.substr(this.resolvedOptions.maximumFractionDigits*-1);
          e.target.value = pre+this.decimalSeparator+post;
        }
      }

      e.target.value = this.parseDisplay(e.target.value);

      /*
        If after formatting, we now have more non numerals (thousand separators, decimal separators, currency symbols, etc), shift the caret forward or
        backwards the difference. (Say we go from 2 separators to 3, we move the caret forward 1.). We also check for a significant change to detect
        for the user doing either a full copy and paste or partial copy and paste.
      */
      const currentValLen = e.target.value.replace(new RegExp(this.thousandSeparator, "g"), "").length;
      const pastValLen = this.pastVal.replace(new RegExp(this.thousandSeparator, "g"), "").length;

      if (Math.abs(currentValLen - pastValLen) > 1) {
        caretPos = e.target.selectionEnd ?? e.target.value.length;
      } else {
        // Otherwise, adjust the caret based on any added/removed non numbers.
        const newNonNums = this.getNonNumbers(e.target.value).length;
        const oldNonNums = this.getNonNumbers(this.pastVal).length;

        if (newNonNums !== oldNonNums) {
          const shift = newNonNums - oldNonNums;

          caretPos = caretPos + shift;
        }
      }

      this.args.setValue(
        this.args.dataFormatting ? e.target.value : this.formatter(e.target.value)
      );

      this.pastVal = e.target.value;
      this.setCaretPos(e.target, caretPos);
    }

    <template>
      <input
        name={{@name}}
        type="text"
        id={{@fieldId}}
        value={{this.displayed}}
        aria-invalid={{if @invalid "true"}}
        aria-describedBy={{if @invalid @errorId}}
        ...attributes
        {{on "input" this.handleInput }}
      />
    </template>
}
