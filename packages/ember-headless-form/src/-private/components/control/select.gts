import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { action } from '@ember/object';

import HeadlessFormControlSelectOptionComponent from './select/option';

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
        Option: WithBoundArgs<
          typeof HeadlessFormControlSelectOptionComponent,
          'selected'
        >;
      }
    ];
  };
}

export default class HeadlessFormControlSelectComponent extends Component<HeadlessFormControlSelectComponentSignature> {
  @action
  handleInput(e: Event | InputEvent): void {
    this.args.setValue((e.target as HTMLSelectElement).value);
  }

  <template>
    <select
      name={{@name}}
      value={{@value}}
      id={{@fieldId}}
      aria-invalid={{if @invalid "true"}}
      aria-describedby={{if @invalid @errorId}}
      ...attributes
      {{on "input" this.handleInput}}
    >
      {{yield
        (hash
          Option=(component
            HeadlessFormControlSelectOptionComponent selected=@value
          )
        )
      }}
    </select>
  </template>
}
