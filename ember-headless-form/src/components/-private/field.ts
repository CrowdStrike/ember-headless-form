import Component from '@glimmer/component';
import { HeadlessFormData } from '../headless-form';

export interface HeadlessFormFieldComponentSignature<
  DATA extends HeadlessFormData
> {
  Args: {
    data: Partial<DATA>;
    name: keyof DATA;
  };
  Blocks: {
    default: [];
  };
}

export default class HeadlessFormComponent<
  DATA extends HeadlessFormData
> extends Component<HeadlessFormFieldComponentSignature<DATA>> {
  get value(): DATA[keyof DATA] | undefined {
    return this.args.data[this.args.name];
  }
}
