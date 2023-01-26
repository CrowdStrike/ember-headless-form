import Component from '@glimmer/component';
import { action } from '@ember/object';

export interface HeadlessFormControlCheckboxComponentSignature {
  Element: HTMLInputElement;
  Args: {
    value: boolean;
    fieldId: string;
    setValue: (value: boolean) => void;
    invalid: boolean;
    errorId: string;
  };
}

export default class HeadlessFormControlCheckboxComponent extends Component<HeadlessFormControlCheckboxComponentSignature> {
  @action
  handleInput(e: Event | InputEvent): void {
    this.args.setValue((e.target as HTMLInputElement).checked);
  }
}
