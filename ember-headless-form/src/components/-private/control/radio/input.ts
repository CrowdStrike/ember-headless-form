import templateOnlyComponent from '@ember/component/template-only';

export interface HeadlessFormControlRadioInputComponentSignature {
  Element: HTMLInputElement;
  Args: {
    value: string;
    name: string;
    checked: boolean;
    fieldId: string;
    setValue: (value: string) => void;
  };
}

export default templateOnlyComponent<HeadlessFormControlRadioInputComponentSignature>();
