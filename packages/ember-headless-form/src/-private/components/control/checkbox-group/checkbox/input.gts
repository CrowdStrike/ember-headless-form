import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { action } from '@ember/object';

export interface HeadlessFormControlCheckboxInputComponentSignature {
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
    toggleValue: (value: boolean) => void;
  };
}

export default class HeadlessFormControlCheckboxComponent extends Component<HeadlessFormControlCheckboxInputComponentSignature> {
  @action
  handleInput(e: Event | InputEvent): void {
    this.args.toggleValue((e.target as HTMLInputElement).checked);
  }

  <template>
    <input
      name={{@name}}
      type="checkbox"
      value={{@value}}
      checked={{@checked}}
      id={{@fieldId}}
      ...attributes
      {{on "change" this.handleInput}}
    />
  </template>
}
