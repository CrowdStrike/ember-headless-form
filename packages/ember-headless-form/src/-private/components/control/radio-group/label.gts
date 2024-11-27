import type { TemplateOnlyComponent } from '@ember/component/template-only';

export interface HeadlessFormControlRadioGroupLabelComponentSignature {
  Element: HTMLDivElement;
  Args: {
    // the following are private arguments curried by the component helper, so users will never have to use those

    /**
     * @internal
     */
    id: string;
  };
  Blocks: {
    default: [];
  };
}

const HeadlessFormControlRadioGroupLabelComponent: TemplateOnlyComponent<HeadlessFormControlRadioGroupLabelComponentSignature> =
  <template><div id={{@id}} ...attributes>{{yield}}</div></template>;

export default HeadlessFormControlRadioGroupLabelComponent;
