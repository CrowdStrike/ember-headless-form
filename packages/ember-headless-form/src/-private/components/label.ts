import templateOnlyComponent from '@ember/component/template-only';

export interface HeadlessFormLabelComponentSignature {
  Element: HTMLLabelElement;
  Args: {
    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    fieldId: string;
  };
  Blocks: {
    default: [];
  };
}

export default templateOnlyComponent<HeadlessFormLabelComponentSignature>();
