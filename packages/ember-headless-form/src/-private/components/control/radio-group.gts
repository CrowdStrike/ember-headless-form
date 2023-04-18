import { hash } from '@ember/helper';

import { uniqueId } from '../../utils';
import HeadlessFormControlRadioGroupLabelComponent from './radio-group/label';
import HeadlessFormControlRadioComponent from './radio-group/radio';

import type { TemplateOnlyComponent } from '@ember/component/template-only';
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
          typeof HeadlessFormControlRadioComponent,
          'name' | 'selected' | 'setValue'
        >;

        Label: WithBoundArgs<
          typeof HeadlessFormControlRadioGroupLabelComponent,
          'id'
        >;
      }
    ];
  };
}

const HeadlessFormControlRadioGroupComponent: TemplateOnlyComponent<HeadlessFormControlRadioGroupComponentSignature> =
  <template>
    {{#let (uniqueId) as |labelId|}}
      <div
        role="radiogroup"
        aria-labelledby={{labelId}}
        aria-invalid={{if @invalid "true"}}
        aria-describedby={{if @invalid @errorId}}
        ...attributes
      >
        {{yield
          (hash
            Radio=(component
              HeadlessFormControlRadioComponent
              name=@name
              selected=@selected
              setValue=@setValue
            )
            Label=(component
              HeadlessFormControlRadioGroupLabelComponent id=labelId
            )
          )
        }}
      </div>
    {{/let}}
  </template>;

export default HeadlessFormControlRadioGroupComponent;
