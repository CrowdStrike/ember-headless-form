/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

module('Integration Component HeadlessForm > Select', function (hooks) {
  setupRenderingTest(hooks);

  test('field yields select component', async function (assert) {
    const data: { selected?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="selected" as |field|>
          <field.Select class="my-select" data-test-select />
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('select')
      .exists('renders a select')
      .hasAttribute('name', 'selected')
      .hasClass('my-select', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-select',
        '',
        'it accepts arbitrary HTML attributes'
      );
  });

  test('select yields option component', async function (assert) {
    const data: { selected?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="selected" as |field|>
          <field.Select as |select|>
            <select.Option @value="foo" data-test-option-foo>Foo</select.Option>
            <select.Option @value="bar" data-test-option-bar>Bar</select.Option>
          </field.Select>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert.dom('select > option').exists({ count: 2 }, 'renders options');

    assert
      .dom('option[data-test-option-foo]')
      .hasText('Foo')
      .hasAttribute('value', 'foo');

    assert
      .dom('option[data-test-option-bar]')
      .hasText('Bar')
      .hasAttribute('value', 'bar');
  });

  test('selected property is mapped correctly to @data', async function (assert) {
    const data: { selected?: string } = { selected: 'bar' };

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="selected" as |field|>
          <field.Select as |select|>
            <select.Option @value="foo" data-test-option-foo>Foo</select.Option>
            <select.Option @value="bar" data-test-option-bar>Bar</select.Option>
          </field.Select>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert.dom('option[data-test-option-foo]').doesNotHaveAttribute('selected');
    assert.dom('option[data-test-option-bar]').hasAttribute('selected');
  });
});
