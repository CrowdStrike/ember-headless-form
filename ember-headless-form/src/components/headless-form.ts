import Component from '@glimmer/component';
import { action } from '@ember/object';

import { TrackedObject } from 'tracked-built-ins';

import FieldComponent from './-private/field';

import type {
  HeadlessFormFieldComponentSignature,
} from './-private/field';
import type { ComponentLike,WithBoundArgs } from '@glint/template';

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

  internalData: DATA = new TrackedObject(this.args.data ?? {}) as DATA;

  @action
  onSubmit(e: Event): void {
    e.preventDefault();

    this.args.onSubmit?.(this.internalData);
  }

  @action
  set<KEY extends keyof DATA>(key: KEY, value: DATA[KEY]): void {
    this.internalData[key] = value;
  }
}
