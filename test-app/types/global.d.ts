import '@glint/environment-ember-loose';
import '@glint/environment-ember-template-imports';

import type { HelperLike } from '@glint/template';
import type HeadlessFormRegistry from 'ember-headless-form/template-registry';

// Types for compiled templates
// declare module 'test-app/templates/*' {
//   import { TemplateFactory } from 'ember-cli-htmlbars';

//   const tmpl: TemplateFactory;
//   export default tmpl;
// }

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry extends HeadlessFormRegistry {
    'page-title': HelperLike<{
      Args: { Positional: [title: string] };
      Return: void;
    }>;
  }
}
