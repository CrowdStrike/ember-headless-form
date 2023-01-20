import templateOnlyComponent from '@ember/component/template-only';

export interface HeadlessFormFieldLabelComponentSignature {
  Element: HTMLLabelElement;
  Args: {
    fieldId: string;
  };
  Blocks: {
    default: [];
  };
}

export default templateOnlyComponent<HeadlessFormFieldLabelComponentSignature>();
