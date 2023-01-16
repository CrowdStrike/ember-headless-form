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
        field: WithBoundArgs<typeof FieldComponent<DATA>, 'data'>;
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
  internalData: Partial<DATA> = this.args.data ?? {};

  @action
  onSubmit() {
    // @todo
    if (this.args.data) {
      this.args.onSubmit?.(this.args.data);
    }
  }
}
