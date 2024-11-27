import Component from '@glimmer/component';
import { hash } from '@ember/helper';

import { uniqueId } from '../../../utils';
import HeadlessFormLabelComponent from '../../label';
import HeadlessFormControlRadioInputComponent from './radio/input';

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
        Label: WithBoundArgs<typeof HeadlessFormLabelComponent, 'fieldId'>;

        /**
         * Yielded component that renders the `<input type="radio">` element.
         */
        Input: WithBoundArgs<
          typeof HeadlessFormControlRadioInputComponent,
          'fieldId' | 'value' | 'setValue' | 'checked' | 'name'
        >;
      }
    ];
  };
}

export default class HeadlessFormControlRadioComponent extends Component<HeadlessFormControlRadioComponentSignature> {
  get isChecked(): boolean {
    return this.args.selected === this.args.value;
  }

  <template>
    {{#let (uniqueId) as |uuid|}}
      {{yield
        (hash
          Label=(component HeadlessFormLabelComponent fieldId=uuid)
          Input=(component
            HeadlessFormControlRadioInputComponent
            name=@name
            fieldId=uuid
            value=@value
            checked=this.isChecked
            setValue=@setValue
          )
        )
      }}
    {{/let}}
  </template>
}
