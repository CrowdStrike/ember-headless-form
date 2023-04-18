import type { TemplateOnlyComponent } from '@ember/component/template-only';

export interface HeadlessFormLabelComponentSignature {
  Element: HTMLLabelElement;
  Args: {
    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    fieldId: string;
  };
  Blocks: {
    default: [];
  };
}

const HeadlessFormLabelComponent: TemplateOnlyComponent<HeadlessFormLabelComponentSignature> =
  <template>
    <label for={{@fieldId}} ...attributes>
      {{yield}}
    </label>
  </template>;

export default HeadlessFormLabelComponent;
