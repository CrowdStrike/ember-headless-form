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
    data: Partial<DATA>;
    name: KEY;
    set: (key: KEY, value: unknown) => void;
  };
  Blocks: {
    default: [
      {
        label: WithBoundArgs<typeof LabelComponent, 'fieldId'>;
        input: WithBoundArgs<
          typeof InputComponent,
          'fieldId' | 'value' | 'setValue'
        >;
        value: DATA[KEY] | undefined;
        id: string;
        setValue: (value: unknown) => void;
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
  InputComponent: ComponentLike<HeadlessFormControlInputComponentSignature> =
    InputComponent;

  get value(): DATA[KEY] | undefined {
    return this.args.data[this.args.name];
  }

  // @todo rethink this?
  get valueAsString(): string | undefined {
    return this.value !== undefined ? String(this.value) : undefined;
  }
}
