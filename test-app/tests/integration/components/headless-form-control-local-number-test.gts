import { render, typeIn } from '@ember/test-helpers';
import { module, skip, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

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

  // Format this number in an English USA Locale.
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

    const options = {
      "style":"currency",
      "currency":"USD"
    };

    await render(
      <template>
        <HeadlessForm as |form|>
          <form.Field @name="localNum" as |field| >
            <field.LocalNumber
              @locale='en-US'
              @formatOptions={{options}}
             />
          </form.Field>
        </HeadlessForm>
      </template>);

      await typeIn("input", "123456.78");

      const inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

      assert.strictEqual(inputValue, "$123,456.78", "input renders US dollars correctly");
  })

  // Correctly format number upon input
  test("formatting between inputs", async function(assert) {
    const options = {
      "style":"currency",
      "currency":"USD"
    };

    await render(
    <template>
      <HeadlessForm as |form|>
        <form.Field @name="localNum" as |field| >
          <field.LocalNumber
            @locale='en-US'
            @formatOptions={{options}}
          />
        </form.Field>
      </HeadlessForm>
    </template>);

    await typeIn("input", "0.02", {delay:1});

    let inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

    assert.strictEqual(inputValue, "$0.02", "input formats correctly for number entry.");

    await typeIn("input", "123", {delay:20});

    inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

    assert.strictEqual(inputValue, "$21.23", "input formats correctly for additional entry.");

    })

    // Right-side input working correctly transferring to integer portion on dollars. Ex, input 125 is turned into $1.25 and not $100.25
    test("Formatting right side entry and handling decimal jump", async function(assert) {
    const options = {
      "style":"currency",
      "currency":"USD"
    };

    await render(
    <template>
      <HeadlessForm as |form|>
        <form.Field @name="localNum" as |field| >
          <field.LocalNumber
            @locale='en-US'
            @formatOptions={{options}}
            @value="0.00"
          />
        </form.Field>
      </HeadlessForm>
    </template>);

    await typeIn("input", "125");

    let inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

    assert.strictEqual(inputValue, "$1.25", "input formats correctly for number entry.");

    await typeIn("input", ".");

    assert.strictEqual(this.element.querySelector("input").selectionStart, 3, "double entry of decimal point jumps to correct position");
    })

  // display non-latin numbers correctly (ex, arabic.) 123456.789 = '١٢٣٬٤٥٦٫٧٨٩'
  test("Displaying arabic number (١٢٣٬٤٥٦٫٧٨٩ = ١٢٣٬٤٥٦٫٧٨٩) correctly", async function(assert) {

    await render(
    <template>
      <HeadlessForm as |form|>
        <form.Field @name="localNum" as |field| >
          <field.LocalNumber
            @locale='ar-SA'
          />
        </form.Field>
      </HeadlessForm>
    </template>);

    await typeIn("input", "١٢٣٤٥٦٫٧٨٩");

    let inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

    assert.strictEqual(inputValue, "١٢٣٬٤٥٦٫٧٨٩", "input formats correctly for number entry.");
  })

  // Arabic leading zero decimal input. 123456.001 = ١٢٣٬٤٥٦٫٠٠١
  test("Leading zero decimal input for arabic. (١٢٣٬٤٥٦٫٠٠١ = ١٢٣٤٥٦٫٠٠١)", async function(assert) {

    await render(
    <template>
      <HeadlessForm as |form|>
        <form.Field @name="localNum" as |field| >
          <field.LocalNumber
            @locale='ar-SA'
          />
        </form.Field>
      </HeadlessForm>
    </template>);

    await typeIn("input", "١٢٣٤٥٦٫٠٠١");

    let inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

    assert.strictEqual(inputValue, "١٢٣٬٤٥٦٫٠٠١", "input formats arabic leading zeros correctly");
  })

  // correct caret positioning for written out currencies. (ex positioning is correct for "$" and "US dollars" respectively)
  // TODO: Skipped for now. Will add full feature support of Intl.NumberFormat in future.
  skip("Correct caret positioning for 'name' currency display formats. Ex: 100 US dollars", async function(assert) {

    const options = {
      "style":"currency",
      "currency":"USD",
      "currencyDisplay":"name"
    };

    await render(
    <template>
      <HeadlessForm as |form|>
        <form.Field @name="localNum" as |field| >
          <field.LocalNumber
            @locale='en-US'
            @formatOptions={{options}}
          />
        </form.Field>
      </HeadlessForm>
    </template>);

    await typeIn("input", "123456.789");

    let inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

    assert.strictEqual(inputValue, "1,234,567.89 US dollars", "input formats long currency displays");
  })

  // formatting to percentages
  // TODO: Skipped for now. Will add full feature support of Intl.NumberFormat in future.
  skip("correct formatting for percentages", async function(assert) {

    const options = {
      "style":"percent",
    };

    await render(
    <template>
      <HeadlessForm as |form|>
        <form.Field @name="localNum" as |field| >
          <field.LocalNumber
            @locale='en-US'
            @formatOptions={{options}}
          />
        </form.Field>
      </HeadlessForm>
    </template>);

    await typeIn("input", "123456");

    let inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

    assert.strictEqual(inputValue, "123456%", "input formats long currency displays");
  })
})
