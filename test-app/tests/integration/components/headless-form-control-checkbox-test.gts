/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from '@crowdstrike/ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

module('Integration Component HeadlessForm > Checkbox', function (hooks) {
  setupRenderingTest(hooks);

  test('field yields checkbox component', async function (assert) {
    const data: { checked?: boolean } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="checked" as |field|>
          <field.Checkbox class="my-input" data-test-checkbox />
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('input')
      .exists('render an input')
      .hasAttribute('type', 'checkbox')
      .hasAttribute('name', 'checked')
      .hasClass('my-input', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-checkbox',
        '',
        'it accepts arbitrary HTML attributes'
      );
  });

  test('checked property is mapped correctly to @data', async function (assert) {
    const data = { checked: true };

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="checked" as |field|>
          <field.Checkbox />
        </form.Field>
      </HeadlessForm>
    </template>);

    assert.dom('input[type="checkbox"]').isChecked();
  });
});
