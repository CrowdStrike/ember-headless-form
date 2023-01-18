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
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> {
  Args: {
    data: DATA;
    name: KEY;
    set: (key: KEY, value: DATA[KEY]) => void;
  };
  Blocks: {
    default: [
      {
        label: WithBoundArgs<typeof LabelComponent, 'fieldId'>;
        input: WithBoundArgs<
          typeof InputComponent<DATA[KEY]>,
          'fieldId' | 'value' | 'setValue'
        >;
        value: DATA[KEY];
        id: string;
        setValue: (value: DATA[KEY]) => void;
      }
    ];
  };
}

export default class HeadlessFormFieldComponent<
  DATA extends HeadlessFormData,
  KEY extends keyof DATA = keyof DATA
> extends Component<HeadlessFormFieldComponentSignature<DATA, KEY>> {
  LabelComponent: ComponentLike<HeadlessFormFieldLabelComponentSignature> =
    LabelComponent;
  InputComponent: ComponentLike<
    HeadlessFormControlInputComponentSignature<DATA[KEY]>
  > = InputComponent;

  get value(): DATA[KEY] {
    return this.args.data[this.args.name];
  }
}
