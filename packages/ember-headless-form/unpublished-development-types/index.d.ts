// Add any types here that you need for local development only.
// These will *not* be published as part of your addon, so be careful that your published code does not rely on them!

import '@glint/environment-ember-loose';

import type HeadlessFormRegistry from '../src/template-registry';

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry extends HeadlessFormRegistry {
    // Add any registry entries from other addons here that your addon itself uses (in non-strict mode templates)
    // See https://typed-ember.gitbook.io/glint/using-glint/ember/using-addons
  }
}

// copy pasted from https://github.com/ember-polyfills/ember-cached-decorator-polyfill/blob/main/index.d.ts
// Once we are on Ember 4.12 and are using their native types instead of `types/*` packages, we can remove this!
declare module '@glimmer/tracking' {
  /**
   * @decorator
   *
   * Memoizes the result of a getter based on autotracking.
   *
   * The `@cached` decorator can be used on native getters to memoize their return
   * values based on the tracked state they consume while being calculated.
   *
   * By default a getter is always re-computed every time it is accessed. On
   * average this is faster than caching every getter result by default.
   *
   * However, there are absolutely cases where getters are expensive, and their
   * values are used repeatedly, so memoization would be very helpful.
   * Strategic, opt-in memoization is a useful tool that helps developers
   * optimize their apps when relevant, without adding extra overhead unless
   * necessary.
   *
   * @example
   *
   * ```ts
   * import { tracked, cached } from '@glimmer/tracking';
   *
   * class Person {
   *   @tracked firstName = 'Jen';
   *   @tracked lastName = 'Weber';
   *
   *   @cached
   *   get fullName() {
   *     return `${this.firstName} ${this.lastName}`;
   *   }
   * }
   * ```
   */
  export let cached: PropertyDecorator;
}
