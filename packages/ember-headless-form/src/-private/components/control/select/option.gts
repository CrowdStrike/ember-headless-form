import Component from '@glimmer/component';

export interface HeadlessFormControlSelectOptionComponentSignature {
  Element: HTMLOptionElement;
  Args: {
    /**
     * The select's value when this option is selected
     */
    value: string;

    // the following are private arguments curried by the component helper, so users will never have to use those

    /*
     * @internal
     */
    selected: string;
  };
  Blocks: {
    default: [];
  };
}

export default class HeadlessFormControlSelectOptionComponent extends Component<HeadlessFormControlSelectOptionComponentSignature> {
  get isSelected(): boolean {
    return this.args.selected === this.args.value;
  }

  <template>
    {{!
Ember seems to insist to set \`selected\` as a property instead of an attribute.
But an attribute is needed if you want to use this with SSR/FastBoot, so the selected option is preselected before JS has loaded.
Using this wonky workaround for now.
See https://github.com/emberjs/ember.js/issues/19115
}}
    {{#if this.isSelected}}
      <option value={{@value}} selected ...attributes>{{yield}}</option>
    {{else}}
      <option value={{@value}} ...attributes>{{yield}}</option>
    {{/if}}
  </template>
}
