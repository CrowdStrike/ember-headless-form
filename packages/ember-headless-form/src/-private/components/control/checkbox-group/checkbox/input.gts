import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

import type { TemplateOnlyComponent } from '@ember/component/template-only';

export interface HeadlessFormControlCheckboxInputComponentSignature {
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

const HeadlessFormControlCheckboxInputComponent: TemplateOnlyComponent<HeadlessFormControlCheckboxInputComponentSignature> =
  <template>
    <input
      name={{@name}}
      type="checkbox"
      value={{@value}}
      checked={{@checked}}
      id={{@fieldId}}
      ...attributes
      {{on "change" (fn @setValue @value)}}
    />
  </template>;

export default HeadlessFormControlCheckboxInputComponent;
