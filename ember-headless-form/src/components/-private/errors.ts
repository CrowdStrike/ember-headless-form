import templateOnlyComponent from '@ember/component/template-only';

import type { ValidationError } from '../headless-form';

export interface HeadlessFormErrorsComponentSignature {
  Element: HTMLDivElement;
  Args: {
    errors: ValidationError[];
  };
  Blocks: {
    default?: [ValidationError[]];
  };
}

export default templateOnlyComponent<HeadlessFormErrorsComponentSignature>();
