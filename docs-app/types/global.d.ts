// Types for compiled templates
declare module 'docs-app/templates/*' {
  import type { TemplateFactory } from 'ember-cli-htmlbars';

  const tmpl: TemplateFactory;
  export default tmpl;
}

declare module '*.css' {
  const styles: { [className: string]: string };
  export default styles;
}

// Types for these are not yet shipped
declare module '@ember/helper';
declare module '@ember/modifier';

// Types for these do not exist
declare module 'highlightjs-glimmer/vendor/highlight.js';
declare module 'highlightjs-glimmer/vendor/javascript.min';
