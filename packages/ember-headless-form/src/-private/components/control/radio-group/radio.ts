import Component from '@glimmer/component';

import LabelComponent from '../../label';
import RadioInputComponent from './radio/input';

import type { WithBoundArgs } from '@glint/template';

export interface HeadlessFormControlRadioComponentSignature {
  Args: {
    /**
     * The value of this individual radio control. All the radios that belong to the same field (have the same name) should have distinct values.
     */
    value: string;

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
  };
  Blocks: {
    default: [
      {
        /**
         * Yielded component that renders the `<label>` of this single radio element.
         */
        Label: WithBoundArgs<typeof LabelComponent, 'fieldId'>;

        /**
         * Yielded component that renders the `<input type="radio">` element.
         */
        Input: WithBoundArgs<
          typeof RadioInputComponent,
          'fieldId' | 'value' | 'setValue' | 'checked' | 'name'
        >;
      }
    ];
  };
}

export default class HeadlessFormControlRadioComponent extends Component<HeadlessFormControlRadioComponentSignature> {
  LabelComponent = LabelComponent;
  RadioInputComponent = RadioInputComponent;

  get isChecked(): boolean {
    return this.args.selected === this.args.value;
  }
}
