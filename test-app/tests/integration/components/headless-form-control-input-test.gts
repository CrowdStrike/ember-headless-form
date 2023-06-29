/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { render, setupOnerror } from '@ember/test-helpers';
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
