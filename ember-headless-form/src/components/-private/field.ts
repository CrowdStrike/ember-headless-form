import Component from '@glimmer/component';
import { HeadlessFormData } from '../headless-form';
import LabelComponent from './field/label';
import { WithBoundArgs } from '@glint/template';

export interface HeadlessFormFieldComponentSignature<
  DATA extends HeadlessFormData
> {
  Args: {
    data: Partial<DATA>;
    name: keyof DATA;
  };
  Blocks: {
    default: [
      {
        label: WithBoundArgs<typeof LabelComponent, 'fieldId'>;
      }
    ];
  };
}

export default class HeadlessFormFieldComponent<
  DATA extends HeadlessFormData
> extends Component<HeadlessFormFieldComponentSignature<DATA>> {
  LabelComponent = LabelComponent;

  get value(): DATA[keyof DATA] | undefined {
    return this.args.data[this.args.name];
  }
}
