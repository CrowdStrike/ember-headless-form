// Add any types here that you need for local development only.
// These will *not* be published as part of your addon, so be careful that your published code does not rely on them!

import '@glint/environment-ember-loose';

import { ComponentLike } from '@glint/template';

import type HeadlessFormRegistry from '../src/template-registry';

// Taken from https://github.com/embroider-build/embroider/blob/main/packages/util/index.d.ts, which is still unreleased.
// @todo Remove once this is publicly available
declare function ensureSafeComponent<C extends string | ComponentLike<S>, S>(
  component: C,
  thingWithOwner: unknown
): C extends string ? ComponentLike<unknown> : C;

declare module '@glint/environment-ember-loose/registry' {
  // Remove this once entries have been added! 👇
  // eslint-disable-next-line @typescript-eslint/no-empty-interface
  export default interface Registry extends HeadlessFormRegistry {
    // Add any registry entries from other addons here that your addon itself uses (in non-strict mode templates)
    // See https://typed-ember.gitbook.io/glint/using-glint/ember/using-addons

    'ensure-safe-component': typeof ensureSafeComponent;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any -- effectively skipping type checks until https://github.com/typed-ember/glint/issues/410 is resolved
    modifier: any;
  }
}
