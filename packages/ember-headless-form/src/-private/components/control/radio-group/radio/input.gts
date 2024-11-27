import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

import type { TemplateOnlyComponent } from '@ember/component/template-only';

export interface HeadlessFormControlRadioInputComponentSignature {
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
    setValue: (value: string) => void;
  };
}

const HeadlessFormControlRadioInputComponent: TemplateOnlyComponent<HeadlessFormControlRadioInputComponentSignature> =
  <template>
    <input
      name={{@name}}
      type="radio"
      value={{@value}}
      checked={{@checked}}
      id={{@fieldId}}
      ...attributes
      {{on "change" (fn @setValue @value)}}
    />
  </template>;

export default HeadlessFormControlRadioInputComponent;
