import Component from '@glimmer/component';
import { action } from '@ember/object';

import OptionComponent from './select/option';

import type { WithBoundArgs } from '@glint/template';

export interface HeadlessFormControlSelectComponentSignature {
  Element: HTMLSelectElement;
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
    fieldId: string;

    /*
     * @internal
     */
    setValue: (value: string) => void;

    /*
     * @internal
     */
    invalid: boolean;

    /*
     * @internal
     */
    errorId: string;
  };
  Blocks: {
    default: [
      {
        Option: WithBoundArgs<typeof OptionComponent, 'selected'>;
      }
    ];
  };
}

export default class HeadlessFormControlSelectComponent extends Component<HeadlessFormControlSelectComponentSignature> {
  OptionComponent = OptionComponent;

  @action
  handleInput(e: Event | InputEvent): void {
    this.args.setValue((e.target as HTMLSelectElement).value);
  }
}
