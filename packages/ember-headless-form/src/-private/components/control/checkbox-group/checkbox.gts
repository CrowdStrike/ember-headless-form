import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { action } from '@ember/object';

import { uniqueId } from '../../../utils';
import HeadlessFormLabelComponent from '../../label';
import HeadlessFormControlCheckboxInputComponent from './checkbox/input';

import type { WithBoundArgs } from '@glint/template';

export interface HeadlessFormControlCheckboxComponentSignature {
  Args: {
    /**
     * The value of this individual checkbox control. All the checkboxs that belong to the same field (have the same name) should have distinct values.
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
    selected: string[];

    /*
     * @internal
     */
    setValue: (value: string[]) => void;
  };
  Blocks: {
    default: [
      {
        /**
         * Yielded component that renders the `<label>` of this single checkbox element.
         */
        Label: WithBoundArgs<typeof HeadlessFormLabelComponent, 'fieldId'>;

        /**
         * Yielded component that renders the `<input type="checkbox">` element.
         */
        Input: WithBoundArgs<
          typeof HeadlessFormControlCheckboxInputComponent,
          'fieldId' | 'value' | 'setValue' | 'checked' | 'name'
        >;
      }
    ];
  };
}

export default class HeadlessFormControlCheckboxComponent extends Component<HeadlessFormControlCheckboxComponentSignature> {
  get isChecked(): boolean {
    return this.args.selected.includes(this.args.value);
  }

  @action
  setValue(value: string): void {
    if (this.args.selected.includes(value)) {
      this.args.setValue([...this.args.selected.filter((v) => v !== value)]);
      } else {
      this.args.setValue([...this.args.selected, value]);
    }
  }

  <template>
    {{#let (uniqueId) as |uuid|}}
      {{yield
        (hash
          Label=(component HeadlessFormLabelComponent fieldId=uuid)
          Input=(component
            HeadlessFormControlCheckboxInputComponent
            name=@name
            fieldId=uuid
            value=@value
            checked=this.isChecked
            setValue=this.setValue
          )
        )
      }}
    {{/let}}
  </template>
}
