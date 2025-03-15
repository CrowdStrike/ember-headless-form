import { click, render, typeIn } from '@ember/test-helpers';
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

  // Support the rendering of currency with right-sided symbol. (French Euro placement.)
  // "123456.78" = "123 456,78 €" This is to ensure input placement is correct.
  // This will need to be manually tested as I don't believe
  // the caret positioning is not currently taken into account by ember test helpers
  // https://github.com/emberjs/ember-test-helpers/issues/1535
  skip("field supports right sided symbol currency placement", async function(assert) {

    const options = {
      "style":"currency",
      "currency":"EUR"
    };

    await render(
      <template>
        <HeadlessForm as |form|>
          <form.Field @name="localNum" as |field| >
            <field.LocalNumber
              @locale='fr-FR'
              @formatOptions={{options}}
             />
          </form.Field>
        </HeadlessForm>
      </template>);

      await typeIn("input", "123456.78");

      const inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

      assert.strictEqual(inputValue, "123 456,78 €", "input renders euros in french locale correctly");
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

    await typeIn("input", "125", {delay:20});

    let input = (this.element.querySelector("input") as HTMLInputElement);

    assert.strictEqual(input.value, "$1.25", "input formats correctly for number entry.");

    await typeIn("input", ".");

    assert.strictEqual(input.selectionStart, 3, "double entry of decimal point jumps to correct position");
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
  test("Correct caret positioning for 'name' currency display formats. Ex: 100 US dollars", async function(assert) {

    const options = {
      style:"currency",
      currency:"USD",
      currencyDisplay:"name"
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

    const inputBox = this.element.querySelector("input") as HTMLInputElement

    await click(inputBox);

    assert.strictEqual(inputBox.selectionStart, 4, "caret position is correct when clicking element");
  })

  // formatting to percentages
  test("correct formatting for percentages", async function(assert) {
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

    assert.strictEqual(inputValue, "123,456%", "input formats percentages correctly");
  })

  // Support for units
  test("correct formatting for unit formats", async function(assert) {
    const options = {
      style:"unit",
      unit:"liter",
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

    await typeIn("input", "123456789", {delay:1});

    let inputValue = (this.element.querySelector("input") as HTMLInputElement).value;

    assert.strictEqual(inputValue, "123,456,789 L", "input formats units correctly");
  })

  // Empty input
  test("empty input resets to zero", async function(assert) {
    await render(
      <template>
        <HeadlessForm as |form|>
          <form.Field @name="localNum" as |field|>
            <field.LocalNumber @locale="en-US" />
          </form.Field>
        </HeadlessForm>
      </template>
    );

    let input = this.element.querySelector("input") as HTMLInputElement;

    await typeIn("input", "");

    // Assuming the default is "0" when no value is provided.
    assert.strictEqual(input.value, "0", "Empty input resets to zero");
  });

  test("invalid input reverts to previous valid state", async function(assert) {

    await render(
      <template>
        <HeadlessForm as |form|>
          <form.Field @name="localNum" as |field|>
            <field.LocalNumber
              @locale="en-US"
              @value="123.45"
            />
          </form.Field>
        </HeadlessForm>
      </template>
    );

    let input = this.element.querySelector("input") as HTMLInputElement;

    await typeIn("input", "abc");

    // It should revert to "123.45"
    assert.strictEqual(input.value, "123.45", "Invalid input reverts to previous valid state");
  });

  /**
   * Skipping because test helpers do not currently take caret position into account when inputting.
   * https://github.com/emberjs/ember-test-helpers/issues/1535
   */
  skip("multiple decimals are handled", async function(assert) {
    const options = {
      style: "currency",
      currency: "USD"
    };

    await render(
      <template>
        <HeadlessForm as |form|>
          <form.Field @name="localNum" as |field|>
            <field.LocalNumber
              @locale="en-US"
              @formatOptions={{options}}
              @value="0.00"
            />
          </form.Field>
        </HeadlessForm>
      </template>
    );

    let input = this.element.querySelector("input") as HTMLInputElement;

    // For example, typing "123.45.67" should result in a properly formatted value.
    await typeIn("input", "12345.67");

    // Adjust the expected value to what your implementation should yield.
    assert.strictEqual(input.value, "$12,367.45", "Extra decimals are collapsed to a single decimal");
  });

})
