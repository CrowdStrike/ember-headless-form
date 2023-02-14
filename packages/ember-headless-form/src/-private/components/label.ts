import templateOnlyComponent from '@ember/component/template-only';

export interface HeadlessFormLabelComponentSignature {
  Element: HTMLLabelElement;
  Args: {
    fieldId: string;
  };
  Blocks: {
    default: [];
  };
}

export default templateOnlyComponent<HeadlessFormLabelComponentSignature>();
