import Component from '@glimmer/component';
import { HeadlessFormData } from '../headless-form';
import LabelComponent from './field/label';
import InputComponent from './control/input';
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
        input: WithBoundArgs<typeof InputComponent, 'fieldId' | 'value'>;
      }
    ];
  };
}

export default class HeadlessFormFieldComponent<
  DATA extends HeadlessFormData
> extends Component<HeadlessFormFieldComponentSignature<DATA>> {
  LabelComponent = LabelComponent;
  InputComponent = InputComponent;

  get value(): DATA[keyof DATA] | undefined {
    return this.args.data[this.args.name];
  }

  // copy-pasted from https://github.com/emberjs/ember.js/blob/master/packages/@ember/-internals/glimmer/lib/helpers/unique-id.ts
  // we can remove this once we only support Ember 4.4+!
  // we could have also used https://github.com/ctjhoa/ember-unique-id-helper-polyfill, but this is a v1 addon and we better keep our addon light-weight
  uniqueId() {
    // @ts-expect-error this one-liner abuses weird JavaScript semantics that
    // TypeScript (legitimately) doesn't like, but they're nonetheless valid and
    // specced.
    return ([3e7] + -1e3 + -4e3 + -2e3 + -1e11).replace(/[0-3]/g, (a) =>
      ((a * 4) ^ ((Math.random() * 16) >> (a & 2))).toString(16)
    );
  }
}
