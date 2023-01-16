import Component from '@glimmer/component';
import { HeadlessFormData } from '../headless-form';
import LabelComponent, {
  HeadlessFormFieldLabelComponentSignature,
} from './field/label';
import InputComponent, {
  HeadlessFormControlInputComponentSignature,
} from './control/input';
import { WithBoundArgs, ComponentLike } from '@glint/template';

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
        input: WithBoundArgs<typeof InputComponent, 'fieldId' | 'value'>;
      }
    ];
  };
}

export default class HeadlessFormFieldComponent<
  DATA extends HeadlessFormData
> extends Component<HeadlessFormFieldComponentSignature<DATA>> {
  LabelComponent: ComponentLike<HeadlessFormFieldLabelComponentSignature> =
    LabelComponent;
  InputComponent: ComponentLike<HeadlessFormControlInputComponentSignature> =
    InputComponent;

  get value(): DATA[keyof DATA] | undefined {
    return this.args.data[this.args.name];
  }

  // @todo rethink this?
  get valueAsString(): string | undefined {
    return this.value !== undefined ? String(this.value) : undefined;
  }
}
