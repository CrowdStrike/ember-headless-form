import Component from '@glimmer/component';
import { action } from '@ember/object';

export interface HeadlessFormControlTextareaComponentSignature {
  Element: HTMLTextAreaElement;
  Args: {
    value: string;
    fieldId: string;
    setValue: (value: string) => void;
    invalid: boolean;
    errorId: string;
  };
}

export default class HeadlessFormControlTextareaComponent extends Component<HeadlessFormControlTextareaComponentSignature> {
  @action
  handleInput(e: Event | InputEvent): void {
    this.args.setValue((e.target as HTMLTextAreaElement).value);
  }
}
