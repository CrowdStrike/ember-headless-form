import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { action } from '@ember/object';

export default class CustomInput extends Component<{
  Element: HTMLInputElement;
  Args: {
    value?: string;
    onChange(value: string): void;
  };
}> {
  @action
  handleInput(e: Event | InputEvent): void {
    this.args.onChange((e.target as HTMLInputElement).value);
  }

  <template>
    <input
      type="text"
      value={{@value}}
      class="border rounded px-2"
      {{on "input" this.handleInput}}
      ...attributes
    />
  </template>
}
