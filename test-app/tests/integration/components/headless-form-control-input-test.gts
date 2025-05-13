/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { fillIn, render, setupOnerror } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { InputType } from 'ember-headless-form';

module('Integration Component HeadlessForm > Input', function (hooks) {
  setupRenderingTest(hooks);

  test('field yields input component', async function (assert) {
    const data: { firstName?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="firstName" as |field|>
          <field.Input class="my-input" data-test-input />
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('input')
      .exists('render an input')
      .hasClass('my-input', 'it accepts custom HTML classes')
      .hasAttribute('name', 'firstName')
      .hasAttribute(
        'data-test-input',
        '',
        'it accepts arbitrary HTML attributes'
      );
  });

  test('input accepts all supported types', async function (assert) {
    const data = { firstName: 'Simon' };
    const inputTypes: InputType[] = [
      'color',
      'date',
      'datetime-local',
      'email',
      'hidden',
      'month',
      'number',
      'password',
      'range',
      'search',
      'tel',
      'text',
      'time',
      'url',
      'week',
    ];

    for (const type of inputTypes) {
      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Input @type={{type}} />
          </form.Field>
        </HeadlessForm>
      </template>);

      assert.dom('input').hasAttribute('type', type, `supports type=${type}`);
    }
  });

  test('number type input accepts values', async function (assert) {
      const data = { amount: 0 };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="amount" as |field|>
            <field.Input @type="number" step="0.01" />
          </form.Field>
        </HeadlessForm>
      </template>);

      /* We are using fillIn here instead of typeIn because typeIn seems to struggle with number inputs that have decimals.
      *   @see https://github.com/emberjs/ember-test-helpers/issues/1546
      */
      await fillIn('input', '12')
      assert.dom("input").hasValue('12', 'allows non-decimal values');
      await fillIn('input', '1.03');
      assert.dom("input").hasValue('1.03', 'allows decimal values');
      await fillIn('input', 'ThisShouldNotWork');
      assert.dom("input").hasValue('0', 'does not allow non-numeric values');
  });


  ['checkbox', 'radio'].forEach((type) =>
    test(`input throws for ${type} type handled by dedicated component`, async function (assert) {
      assert.expect(1);
      setupOnerror((e: Error) => {
        assert.strictEqual(
          e.message,
          `Assertion Failed: input component does not support @type="${type}" as there is a dedicated component for this. Please use the \`field.${type}\` instead!`,
          'Expected assertion error message'
        );
      });

      const data = { checked: false };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="checked" as |field|>
            {{! @glint-expect-error }}
            <field.Input @type={{type}} />
          </form.Field>
        </HeadlessForm>
      </template>);
    })
  );
});
