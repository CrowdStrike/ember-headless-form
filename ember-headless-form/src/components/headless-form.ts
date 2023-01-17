import Component from '@glimmer/component';
import { action } from '@ember/object';
import FieldComponent, {
  HeadlessFormFieldComponentSignature,
} from './-private/field';
import { WithBoundArgs, ComponentLike } from '@glint/template';

export type HeadlessFormData = object;

export interface HeadlessFormComponentSignature<DATA extends HeadlessFormData> {
  Element: HTMLFormElement;
  Args: {
    data?: DATA;
    onSubmit?: (data: DATA) => void;
  };
  Blocks: {
    default: [
      {
        field: WithBoundArgs<typeof FieldComponent<DATA>, 'data' | 'set'>;
      }
    ];
  };
}

export default class HeadlessFormComponent<
  DATA extends HeadlessFormData
> extends Component<HeadlessFormComponentSignature<DATA>> {
  FieldComponent: ComponentLike<HeadlessFormFieldComponentSignature<DATA>> =
    FieldComponent;

  // @todo make a local copy
  internalData: Partial<DATA> = { ...this.args.data } ?? {};

  @action
  onSubmit(e: Event): void {
    e.preventDefault();

    // @todo what's the proper type!?
    this.args.onSubmit?.(this.internalData as DATA);
  }

  @action
  set<KEY extends keyof DATA>(key: KEY, value: DATA[KEY]): void {
    this.internalData[key] = value;
  }
}
