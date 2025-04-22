import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { on } from '@ember/modifier';
import { action }from '@ember/object';

/**
 *  This component works to solve using localized number inputs and will render a text field to support it as
 *  a normal number input field only supports "." as a decimal separator no matter the locale. It will format
 *  the numbers correctly as the user types into the field. When data is presented, it is formatted
 *  into the expected decimal value for data storage. Ex, a German user may type 1.234,56 but this data should be
 *  saved in the database as 1234.56.
 *
 *  You should be able to use the majority of the input options available to Intl.NumberFormat aside from scientific notation
 *  and compact notation.
 */

export interface HeadlessFormControlLocalNumberComponentSignature {
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

class LocalNumberInputValue {
    /**
     * Instance of the Intl.NumberFormat created using arguments provided on initialization
     */
    public readonly toFormatter: Intl.NumberFormat;
    /**
     * Result of Intl.NumberFormat().formatToParts
     */
    public parts!: Array<Intl.NumberFormatPart>;
    /**
     * The "true" stored value of the number we are working with. Ex $1,500.72 would be "1500.72"
     */
    public dataValue!: number;
    /**
     * Resolved options of Intl.NumberFormat
     */
    public readonly resolvedOptions;
    /**
     * Base 10 numbers based on the given locale. Providing support for non-latin numbers.
     */
    public readonly localeNumbers: Array<string>;
    /**
     * Decimal separator for the formatting
     */
    public readonly decimalSep: string;
    /**
     * Negative symbol for formatting
     */
    public readonly negative: string;
    /**
     *
     */
    public readonly dataRegex: RegExp;

    constructor(locale = "en-US", options:Intl.NumberFormatOptions = {}, value:number|string = 0){
      // Build the initial formatter with given options and value then save the parts to use later.
      this.toFormatter = new Intl.NumberFormat(locale, options);
      this.resolvedOptions = this.toFormatter.resolvedOptions();

      // We setup a temporary formatter with only the locale because some formatters like units may mess with the number itself.
      const tmpFormatter = new Intl.NumberFormat(locale, {});

      // Build numbers 0-9 for whatever locale we're working with. Supports base 10 number systems.
      this.localeNumbers = Array.from({ length: 10 }, (_, i) => {
        const parts = tmpFormatter.formatToParts(i);
        const integerPart = parts.find(part => part.type === "integer") ?? {value:<number>i};

        // Account for number formatter multiplying wholes by 100 when doing percentages.
        return integerPart.value;
      }) as Array<string>;

      // Use the temporary formatter to extract parts from "-0.01" to give us both the negative symbol and decimal for the locale.
      const parts = tmpFormatter.formatToParts("-0.01");

      this.decimalSep = parts.find(part => part.type === 'decimal')?.value ?? ".";
      this.negative = parts.find(part => part.type === 'minusSign')?.value ?? "-";

      const sep = this.escapeRegex(this.decimalSep);
      const neg = this.escapeRegex(this.negative);

      // This regex will first serve to only return numbers and the decimal separators
      this.dataRegex = new RegExp(`[^\\p{Nd}(?:${sep}${neg})]+`, 'gu');

      this.updateInput(String(value));
    }

    get preNumLen():number {
      let sum = 0;

      for (const item of this.parts) {
        if (["integer", "fraction", "minusSign"].includes(item.type)) {
          break;
        } else {
          sum += item.value.length;
        }
      }

      return sum;
    }

    get postNumLen():number {
      let sum = 0;

      for (const item of [...this.parts].reverse()) {
        if (["integer", "fraction", "minusSign"].includes(item.type)) {
          break;
        } else {
          sum += item.value.length;
        }
      }

      return sum;
    }

    /**
     * Get the relevant non-number length.
     */
    get nonNumberLength():number {
      return [...this.parts].filter((item) => !["integer", "fraction", "decimal"].includes(item.type)).reduce((total, item) => total + item.value.length, 0);
    }

    /**
    *  Different languages define their zeros differently. For example, arabic uses "٠" while english will use "0".
    *  We need to know what their zero is in order to know when to programmatically run the formatter.
    */
    get zero(): string {
      return this.localeNumbers[0] ?? "0";
    }

    /**
     * Get the formatted value the user might expect.
     */
    get displayedValue() :string {
      return this.toFormatter.format(this.dataValue);
    }

    /**
     * Determine whether or not decimals are used for this formatting type.
     * Will return true if there is a set minimum or max amount of fraction digits and the decimal separator isn't blank.
     */
    get hasDecimals(): boolean {
      return ((this.resolvedOptions.minimumFractionDigits ?? 0) > 0 || (this.resolvedOptions.maximumFractionDigits ?? 0) > 0) && this.decimalSep != "";
    }

    /**
     * Determine whether or not this input has boundaries
     */
    get hasBounds(): boolean {
      return (this.preNumLen ?? 0) > 0 || (this.postNumLen ?? 0) > 0;
    }

    /**
     * Determine whether or not the number is in a saveable state.
     * Inputs are considered invalid if:
     * - they would result in NaN with the data value
     * - they have more than one decimal separator and also should have decimals
     */
    get isValid(): boolean {
      // Skip decimal checks if there isn't one defined.
      if(!this.hasDecimals){
        return !isNaN(this.dataValue);
      }

      // Decimal Checks
      const sections = this.displayedValue.split(this.decimalSep);

      return !(isNaN(this.dataValue) || sections.length > 2)
    }

    /**
     * We will use this method until RegExp.escape is more commonly implemented.
     * https://tc39.es/proposal-regex-escaping/
     * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/escape
     */
    private escapeRegex(toEscape: string): string {
      if(toEscape == ",") return toEscape;

      /*
      Uncomment when we can use it.
      if(RegExp.escape != undefined){
        return RegExp.escape(toEscape);
      }else {
        return toEscape.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
      }*/

      return toEscape.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
    }

    /**
     * Try to get the value by removing irrelevant characters and then performing regex on the substring to remove anything that isn't a number.
     */
    public parseValue(data:string):number {
      // Apply all regex
      let value:string|number = data.replace(this.dataRegex, '');

      // Finally swap out all of locale numbers for the localized numbers.
      // Inspired by: https://github.com/ApelegHQ/intl-number-parser/blob/master/src/NumberParser.ts
      value = this.localeNumbers.reduce((acc,cv,i) => acc.split(cv).join(String(i)), value);

      // swap the locale decimal separator with a period because that's what parseFloat expects.
      if(this.hasDecimals){
        value = value.replace(this.decimalSep, ".");
      }

      value = parseFloat(value);

      // Percentage Support
      if(this.resolvedOptions.style === "percent"){
        value *= 0.01;
      }else{
        value = value.toFixed(this.resolvedOptions.maximumFractionDigits);
      }

      return value as number;
    }

    /**
     * Get the relevant portion of the given string. Ex, "123,456.45 US Dollars" should yield us 123,456.45
     * as determined by the formatting options on this object.
     */
    public getRelevantData(data:string):string{
      if(this.hasBounds){
        data = data.substring(this.preNumLen, data.length - this.postNumLen);
      }

      return data;
    }

    /**
     * Update the value of the input object.
     */
    public updateInput(value:string): void{
      // Extract the actual value by stripping away anything that isn't a number or a decimal.
      this.dataValue = this.parseValue(value);
      // Break up parts and determine the area where the actual number is.
      this.parts = this.toFormatter.formatToParts(this.dataValue);
    }
}

export default class HeadlessFormControlLocalNumberComponent extends Component<HeadlessFormControlLocalNumberComponentSignature>{
    // Value of field before user's previous and most recent input
    private pastVal: LocalNumberInputValue;
    private currentVal: LocalNumberInputValue;

    constructor(
      owner: unknown,
      args: HeadlessFormControlLocalNumberComponentSignature['Args']
    ){
      super(owner, args);

      this.pastVal = new LocalNumberInputValue(this.args.locale, this.args.formatOptions, this.args.value ?? "0");
      this.currentVal = new LocalNumberInputValue(this.args.locale, this.args.formatOptions, this.args.value ?? "0");
    }

    /*
    * Set the user's input to a position on a text box.
    */
    private setCaretPos(elem: HTMLInputElement, caretPos:number, caretPosEnd?:number):void {
      if (document.activeElement == elem) {
        elem.focus();
        elem.setSelectionRange(caretPos, caretPosEnd ?? caretPos);
      }
    }

    /**
     * Reset for invalid inputs.
     * First try to go back to the previous value if it's valid.
     * If the last value isn't valid check if a value was provided and go to that.
     * If there is no value originally provided and the previous input is invalid, default to 0.
     */
    private resetInput(elem: HTMLInputElement): void{
        assert('Expected HTMLInputElement', elem instanceof HTMLInputElement);

        if(this.pastVal.isValid){
          this.currentVal.updateInput(this.pastVal.displayedValue);
        }else if(this.args.value) {
          this.currentVal.updateInput(String(this.args.value));
        }else {
          this.currentVal.updateInput(this.currentVal.zero);
        }

        elem.value = this.currentVal.displayedValue;

        return;
    }

    /**
     * Handler for input events.
     */
    @action
    handleInput(e: Event | InputEvent): void {
      assert('Expected HTMLInputElement', e.target instanceof HTMLInputElement);

      let caretPos: number = e.target.selectionStart ?? 0;
      const relevantData = this.currentVal.getRelevantData(e.target.value);

      // Allow for empty inputs.
      if(relevantData == ""){
        this.args.setValue(0);
        this.currentVal.updateInput(String(this.currentVal.zero));
        e.target.value = this.currentVal.displayedValue;

        return;
      }

      // Allow for initial negative number inputs. Ex, user typing in -0 or 0- or just - likely indicates they want to input a negative number.
      if((relevantData.includes(`${this.currentVal.negative}`) && relevantData.length < 2) || relevantData.includes(`${this.currentVal.negative+this.currentVal.zero}`) || relevantData.includes(`${this.currentVal.zero+this.currentVal.negative}`)){
        this.args.setValue(0);
        this.currentVal.updateInput(String(this.currentVal.zero));
        e.target.value = this.currentVal.negative;

        return;
      }

      this.currentVal.updateInput(e.target.value);
      // Update our current value instance with the new input.

      if(!this.currentVal.isValid){
        this.resetInput(e.target);

        return;
      }

      if(this.currentVal.hasDecimals){
        const decimalPos: number = e.target.value.indexOf(this.currentVal.decimalSep);

        if(decimalPos >= 0){
          const maxDecPlaces = this.currentVal.resolvedOptions.maximumFractionDigits;
          const minDecPlaces = this.currentVal.resolvedOptions.minimumFractionDigits;
          const parts = relevantData.split(this.currentVal.decimalSep);

          // Jump to decimal if there is already one present and the most recent input was a decimal.
          if(parts.length > 2){
            this.resetInput(e.target);
            this.setCaretPos(e.target, decimalPos+1);

            return;
          }

          // Mostly doing this to fix the linter error. It would not typically make it this far without a decimal.
          if(parts[1] != undefined){
            // Allow for precision inputs ex 0.001. But not beyond the max and maintaining the minimum.
            if((relevantData.endsWith(this.currentVal.decimalSep) || (relevantData.endsWith(this.currentVal.zero) && caretPos > decimalPos)) && parts[1].length <= maxDecPlaces && parts[1].length >= minDecPlaces){
              return;
            }

            // Inputs going over the maximum allotted decimal places will shift the fraction into the whole. (Right side input)
            if(parts[1].length > (maxDecPlaces ?? 0)){
              // Split the value by the decimal point to get value before and after.
              let [pre,post = ""] = relevantData.split(this.currentVal.decimalSep);

              // Determine how big of a difference there is between the maximum decimals and the attempted input.
              // This will give us how much we need to shift from the post to the pre.
              const diff = Math.abs(maxDecPlaces - post.length);

              // Shift the value from the fraction to the whole.
              pre = pre+post.substring(0,diff);
              post = post.substring(diff, post.length);

              // Update the input. (Put the decimal place back, recombine the string);
              e.target.value = pre+this.currentVal.decimalSep+post;
              this.currentVal.updateInput(e.target.value);
            }
          }
        }
      }

      const currentNonNums = this.currentVal.nonNumberLength;
      const pastNonNums = this.pastVal.nonNumberLength;

      // Account for changes in non numberical values that would cause the caret to shift.
      if (currentNonNums !== pastNonNums) {
        caretPos += (currentNonNums - pastNonNums);
      }

      e.target.value = this.currentVal.displayedValue;
      this.args.setValue(this.currentVal.dataValue);
      // Update past value.
      this.pastVal.updateInput(e.target.value);
      this.setCaretPos(e.target, caretPos);
    }

    /**
     * Ensures the Caret remains within the bounds of the data and adjusts to whatever is on the start or ends.
     */
    @action
    handleSelectionChange(e: Event | InputEvent): void {
      assert('Expected HTMLInputElement', e.target instanceof HTMLInputElement);

      // Keep input caret within bounds of data.
      if(this.currentVal.hasBounds){
        let caretPos: number = e.target.selectionStart ?? 0;
        const caretEndPos: number = e.target.selectionEnd ?? 0;
        // Determine valid caret range based on current value. (Where is the value)
        const validStart = this.currentVal.preNumLen;
        const validEnd = e.target.value.length - this.currentVal.postNumLen;

        // Handle whole selections (ctrl+a, select all)
        if(caretPos == 0 && e.target.value.length == caretEndPos){
          this.setCaretPos(e.target, validStart, validEnd);

          return;
        }

        // If we're out of bounds, shift it to the closest in bound position.
        if (caretPos < validStart || caretPos > validEnd || caretEndPos < validStart || caretEndPos > validEnd) {
          caretPos = Math.abs(caretPos - validStart) < Math.abs(caretPos - validEnd) ? validStart : validEnd;
          this.setCaretPos(e.target, caretPos);
        }
      }
    }

    <template>
      <input
        name={{@name}}
        type="text"
        id={{@fieldId}}
        value={{this.currentVal.displayedValue}}
        aria-invalid={{if @invalid "true"}}
        aria-describedBy={{if @invalid @errorId}}
        inputmode="decimal"
        ...attributes
        {{on "input" this.handleInput }}
        {{on "selectionchange" this.handleSelectionChange }}
      />
    </template>
}
