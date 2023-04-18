import Component from '@glimmer/component';

import type { ValidationError } from '../types';

export interface HeadlessFormErrorsComponentSignature<VALUE> {
  Element: HTMLDivElement;
  Args: {
    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    errors: ValidationError<VALUE>[];

    /*
     * @internal
     */
    id: string;
  };
  Blocks: {
    default?: [ValidationError<VALUE>[]];
  };
}

// eslint-disable-next-line ember/no-empty-glimmer-component-classes -- unfortunately we cannot use templateOnlyComponent() here, as it is not possible to type that as a generic type, like templateOnlyComponent<HeadlessFormErrorsComponentSignature<VALUE>>
export default class HeadlessFormErrorsComponent<VALUE> extends Component<
  HeadlessFormErrorsComponentSignature<VALUE>
> {
  <template>
    <div id={{@id}} aria-live="assertive" ...attributes>
      {{#if (has-block)}}
        {{yield @errors}}
      {{else}}
        {{#each @errors as |e|}}
          {{#if e.message}}
            {{e.message}}<br />
          {{/if}}
        {{/each}}
      {{/if}}
    </div>
  </template>
}
