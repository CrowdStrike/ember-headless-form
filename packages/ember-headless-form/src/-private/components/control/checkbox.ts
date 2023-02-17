import Component from '@glimmer/component';
import { action } from '@ember/object';

export interface HeadlessFormControlCheckboxComponentSignature {
  Element: HTMLInputElement;
  Args: {
    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    value: boolean;

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
    setValue: (value: boolean) => void;

    /*
     * @internal
     */
    invalid: boolean;

    /*
     * @internal
     */
    errorId: string;
  };
}

export default class HeadlessFormControlCheckboxComponent extends Component<HeadlessFormControlCheckboxComponentSignature> {
  @action
  handleInput(e: Event | InputEvent): void {
    this.args.setValue((e.target as HTMLInputElement).checked);
  }
}
