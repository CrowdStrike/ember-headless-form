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
}
