import { hash } from '@ember/helper';

import { uniqueId } from '../../utils';
import HeadlessFormControlCheckboxComponent from './checkbox-group/checkbox';
import HeadlessFormControlCheckboxGroupLabelComponent from './checkbox-group/label';

import type { TemplateOnlyComponent } from '@ember/component/template-only';
import type { WithBoundArgs } from '@glint/template';

export interface HeadlessFormControlCheckboxGroupComponentSignature {
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
    selected: string[];

    /*
     * @internal
     */
    setValue: (value: string[]) => void;

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
         * Yielded component that renders the `<input type="checkbox">` element.
         */
        Checkbox: WithBoundArgs<
          typeof HeadlessFormControlCheckboxComponent,
          'name' | 'selected' | 'setValue'
        >;

        Label: WithBoundArgs<
          typeof HeadlessFormControlCheckboxGroupLabelComponent,
          'id'
        >;
      }
    ];
  };
}

const HeadlessFormControlCheckboxGroupComponent: TemplateOnlyComponent<HeadlessFormControlCheckboxGroupComponentSignature> =
  <template>
    {{#let (uniqueId) as |labelId|}}
      <div
        role="group"
        aria-labelledby={{labelId}}
        aria-invalid={{if @invalid "true"}}
        aria-describedby={{if @invalid @errorId}}
        ...attributes
      >
        {{yield
          (hash
            Checkbox=(component
              HeadlessFormControlCheckboxComponent
              name=@name
              selected=@selected
              setValue=@setValue
            )
            Label=(component
              HeadlessFormControlCheckboxGroupLabelComponent id=labelId
            )
          )
        }}
      </div>
    {{/let}}
  </template>;

export default HeadlessFormControlCheckboxGroupComponent;
