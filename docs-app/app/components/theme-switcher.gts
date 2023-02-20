import { on } from '@ember/modifier';

import { DARK } from '@crowdstrike/ember-toucan-styles';
import service from 'docs-app/helpers/service';

import type { TOC } from '@ember/component/template-only';

const eq = (a: string, b: string) => a === b;

const ThemeSwitcher: TOC<{
  Element: HTMLButtonElement;
}> = <template>
  {{#let (service 'theme-manager') as |themeManager|}}
    <button
      type="button"
      class="focusable duration-150 ease-out rounded-sm transition interactive-quiet px-3"
      ...attributes
      {{on "click" themeManager.toggleTheme}}
    >
      {{#if (eq themeManager.currentTheme DARK)}}
        <span class="sr-only">
          Switch to Light Mode
        </span>
        <svg
          aria-hidden="true"
          class="w-6 h-6"
          fill="currentColor"
          viewBox="0 0 20 20"
        >
          <path
            d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"
          ></path>
        </svg>
      {{else}}
        <span class="sr-only">
          Switch to Dark Mode
        </span>
        <svg
          aria-hidden="true"
          class="w-6 h-6"
          fill="currentColor"
          viewBox="0 0 20 20"
        >
          <path
            d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z"
            clip-rule="evenodd"
            fill-rule="evenodd"
          ></path>
        </svg>
      {{/if}}
    </button>

  {{/let}}
</template>

export default ThemeSwitcher;
