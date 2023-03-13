import templateOnlyComponent from '@ember/component/template-only';

export interface HeadlessFormControlRadioInputComponentSignature {
  Element: HTMLInputElement;
  Args: {
    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    value: string;

    /*
     * @internal
     */
    name: string;

    /*
     * @internal
     */
    checked: boolean;

    /*
     * @internal
     */
    fieldId: string;

    /*
     * @internal
     */
    setValue: (value: string) => void;
  };
}

export default templateOnlyComponent<HeadlessFormControlRadioInputComponentSignature>();
