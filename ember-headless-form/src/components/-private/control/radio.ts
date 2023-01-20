import Component from '@glimmer/component';

import LabelComponent from '../label';
import RadioInputComponent from './radio/input';

import type { HeadlessFormLabelComponentSignature } from '../label';
import type { HeadlessFormControlRadioInputComponentSignature } from './radio/input';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

export interface HeadlessFormControlRadioComponentSignature {
  Args: {
    value: string;
    selected: string;
    setValue: (value: string) => void;
  };
  Blocks: {
    default: [
      {
        label: WithBoundArgs<typeof LabelComponent, 'fieldId'>;
        input: WithBoundArgs<
          typeof RadioInputComponent,
          'fieldId' | 'value' | 'setValue' | 'checked'
        >;
      }
    ];
  };
}

export default class HeadlessFormControlRadioComponent extends Component<HeadlessFormControlRadioComponentSignature> {
  LabelComponent: ComponentLike<HeadlessFormLabelComponentSignature> =
    LabelComponent;
  RadioInputComponent: ComponentLike<HeadlessFormControlRadioInputComponentSignature> =
    RadioInputComponent;

  get isChecked(): boolean {
    return this.args.selected === this.args.value;
  }

  // @action
  // handleInput(e: Event | InputEvent): void {
  //   const element: HTMLInputElement = e.target;
  //   this.args.setValue((e.target as HTMLInputElement).checked);
  // }
}
