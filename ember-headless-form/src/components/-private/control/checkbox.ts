import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { action } from '@ember/object';

export interface HeadlessFormControlCheckboxComponentSignature {
  Element: HTMLInputElement;
  Args: {
    value: boolean;
    fieldId: string;
    setValue: (value: boolean) => void;
  };
}

export default class HeadlessFormControlCheckboxComponent extends Component<HeadlessFormControlCheckboxComponentSignature> {
  @action
  handleInput(e: Event | InputEvent): void {
    this.args.setValue((e.target as HTMLInputElement).checked);
  }
}
