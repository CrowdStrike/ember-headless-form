import { fillIn,render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { hash } from 'rsvp';
import { setupRenderingTest } from 'test-app/tests/helpers';

//import type { RenderingTestContext } from '@ember/test-helpers';

module("Integration Component HeadlessForm > Local Number", function(hooks) {
  setupRenderingTest(hooks);

  // requires no arguments
  test("field renders as a text input with no arguments", async function(assert){
    await render(
      <template>
        <HeadlessForm as |form|>
          <form.Field @name="localNum" as |field| >
            <field.LocalNumber />
          </form.Field>
        </HeadlessForm>
      </template>);

      const textInput = (this.element.querySelector("input") as HTMLInputElement).type;

      assert.strictEqual(textInput, "text", "form field renders as text with no arguments.");
  })

  // Format this number in an USA Locale.
  test("field renders en-US number correctly", async function(assert) {
    await render(
      <template>
        <HeadlessForm as |form|>
          <form.Field @name="localNum" as |field| >
            <field.LocalNumber
              @locale="en-US"
              @value="123456.789"
             />
          </form.Field>
        </HeadlessForm>
      </template>);

      const inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

      assert.strictEqual(inputValue, "123,456.789", "input renders US formatted numbers correctly")
  })

  // Support the rendering of currency.
  test("field supports formatting options to render currency", async function(assert) {
    await render(
      <template>
        <HeadlessForm as |form|>
          <form.Field @name="localNum" as |field| >
            <field.LocalNumber
              @locale="en-US"
              @formatOptions={{hash style='currency' currency='USD'}}
             />
          </form.Field>
        </HeadlessForm>
      </template>);

      await fillIn("input", "123456.78");

      const inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

      assert.strictEqual(inputValue, "$123,456.78", "input renders US dollars correctly");
  })

  // Correctly format number upon input

  // Right-side input working correctly transferring to integer portion on dollars. Ex, input 125 is turned into $1.25 and not $100.25

  // Shift input to end on whole copy and paste.

  // Shift input to end of selection on partial copy and paste.

  // display non-latin numbers correctly

  // display right-aligned language currencies correctly.

  // formatting to scientific notation.


})
