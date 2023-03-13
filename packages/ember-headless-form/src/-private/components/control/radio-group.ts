import Component from '@glimmer/component';

import LabelComponent from './radio-group/label';
import RadioComponent from './radio-group/radio';

import type { WithBoundArgs } from '@glint/template';

export interface HeadlessFormControlRadioGroupComponentSignature {
  Element: HTMLDivElement;
  Args: {
    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    name: string;

    /*
     * @internal
     */
    selected: string;

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
        /**
         * Yielded component that renders the `<input type="radio">` element.
         */
        Radio: WithBoundArgs<
          typeof RadioComponent,
          'name' | 'selected' | 'setValue'
        >;

        Label: WithBoundArgs<typeof LabelComponent, 'id'>;
      }
    ];
  };
}

export default class HeadlessFormControlRadioGroupComponent extends Component<HeadlessFormControlRadioGroupComponentSignature> {
  RadioComponent = RadioComponent;
  LabelComponent = LabelComponent;
}
