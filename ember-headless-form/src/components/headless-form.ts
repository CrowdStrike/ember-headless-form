import Component from '@glimmer/component';
import { action } from '@ember/object';

export type HeadlessFormData = object;

export interface HeadlessFormComponentSignature<DATA extends HeadlessFormData> {
  Element: HTMLFormElement;
  Args: {
    data: DATA;
    onSubmit?: (data: DATA) => void;
  };
  Blocks: {
    default: [];
  };
}

export default class HeadlessFormComponent<
  DATA extends HeadlessFormData
> extends Component<HeadlessFormComponentSignature<DATA>> {
  //

  @action
  onSubmit() {
    if (this.args.data) {
      this.args.onSubmit?.(this.args.data);
    }
  }
}
