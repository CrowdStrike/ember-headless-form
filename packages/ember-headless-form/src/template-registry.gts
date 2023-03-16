// Easily allow apps, which are not yet using strict mode templates, to consume your Glint types, by importing this file.
// Add all your components, helpers and modifiers to the template registry here, so apps don't have to do this.
// See https://typed-ember.gitbook.io/glint/using-glint/ember/authoring-addons

import type HeadlessFormComponent from './components/headless-form';

export default interface Registry {
  /**
   * Headless form component.
   *
   * @example
   * Usage example:
   *
   * ```hbs
   * <HeadlessForm
   *   @data={{this.data}}
   *   @validateOn="focusout"
   *   @revalidateOn="input"
   *   @onSubmit={{this.doSomething}}
   *   as |form|
   * >
   *   <form.Field @name="firstName" as |field|>
   *     <div>
   *       <field.Label>First name</field.Label>
   *       <field.Input
   *         required
   *       />
   *       <field.errors />
   *     </div>
   *   </form.Field>
   *
   *   <button
   *     type="submit"
   *   >Submit</button>
   * </HeadlessForm>
   * ```
   */
  HeadlessForm: typeof HeadlessFormComponent;
}
