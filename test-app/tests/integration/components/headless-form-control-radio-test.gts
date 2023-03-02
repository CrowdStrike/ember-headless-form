/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from '@crowdstrike/ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { RenderingTestContext } from '@ember/test-helpers';

module('Integration Component HeadlessForm > Radio', function (hooks) {
  setupRenderingTest(hooks);

  test('field yields radio component', async function (assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.Radio @value="foo">
            Some content
          </field.Radio>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert.dom('form').hasText('Some content', 'radio renders block content');

    assert
      .dom('form > *')
      .doesNotExist('radio component contains no markup itself');
  });

  test('radio yields label component', async function (assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.Radio @value="foo" as |radio|>
            <radio.Label class="my-label" data-test-label>Foo</radio.Label>
          </field.Radio>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('label')
      .hasText('Foo', 'it renders block content')
      .hasClass('my-label', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-label',
        '',
        'it accepts arbitrary HTML attributes'
      );
  });

  test('radio yields input component', async function (assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.Radio @value="foo" as |radio|>
            <radio.Input class="my-input" data-test-radio />
          </field.Radio>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('input')
      .exists('render an input')
      .hasAttribute('type', 'radio')
      .hasAttribute('name', 'choice')
      .hasValue('foo')
      .hasClass('my-input', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-radio',
        '',
        'it accepts arbitrary HTML attributes'
      );
  });

  test('label and input are connected', async function (this: RenderingTestContext, assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.Radio @value="foo" as |radio|>
            <radio.Input />
            <radio.Label>Foo</radio.Label>
          </field.Radio>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert.dom('input').hasAttribute(
      'id',
      // copied from https://ihateregex.io/expr/uuid/
      /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/,
      'input has id with dynamically generated uuid'
    );

    const id = this.element.querySelector('input')?.id ?? '';

    assert
      .dom('label')
      .hasAttribute('for', id, 'label is attached to input by `for` attribute');
  });

  test('checked property is mapped correctly to @data', async function (assert) {
    const data: { choice?: string } = { choice: 'bar' };

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.Radio @value="foo" as |radio|>
            <radio.Input data-test-radio1 />
            <radio.Label>Foo</radio.Label>
          </field.Radio>
          <field.Radio @value="bar" as |radio|>
            <radio.Input data-test-radio2 />
            <radio.Label>Bar</radio.Label>
          </field.Radio>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert.dom('input[data-test-radio1]').isNotChecked();
    assert.dom('input[data-test-radio2]').isChecked();
  });
});
