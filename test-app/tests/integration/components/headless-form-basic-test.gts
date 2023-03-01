/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { render, setupOnerror } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { RenderingTestContext } from '@ember/test-helpers';

module('Integration Component HeadlessForm > Basics', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders form markup', async function (assert) {
    await render(<template>
      <HeadlessForm class="foo" autocomplete="off" />
    </template>);

    assert.dom('form').exists('it renders as <form>');
    assert
      .dom('form')
      .hasClass('foo', 'it accepts custom HTML classes')
      .hasAttribute(
        'autocomplete',
        'off',
        'it accepts arbitrary HTML attributes'
      );
  });

  module('form.Field', function () {
    test('form yields field component', async function (assert) {
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName">
            <div data-test-user-content>foo</div>
          </form.Field>
        </HeadlessForm>
      </template>);

      assert
        .dom('[data-test-user-content]')
        .exists('form field can render user content');

      assert
        .dom('form > [data-test-user-content]')
        .exists('field component contains no markup itself');
    });

    test('@name must be unique', async function (assert) {
      assert.expect(1);
      const data = { firstName: 'Simon' };

      setupOnerror((e: Error) => {
        assert.strictEqual(
          e.message,
          'Assertion Failed: You passed @name="firstName" to the form field, but this is already in use. Names of form fields must be unique!',
          'Expected assertion error message'
        );
      });

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" />
          <form.Field @name="firstName" />
        </HeadlessForm>
      </template>);
    });

    test('id is yielded from field component', async function (this: RenderingTestContext, assert) {
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <div data-test-id>{{field.id}}</div>
            <field.Input />
          </form.Field>
        </HeadlessForm>
      </template>);

      const inputId = this.element.querySelector('input')?.id;
      const id = (this.element.querySelector('[data-test-id]') as HTMLElement)
        .innerText;

      assert.strictEqual(id, inputId, "yielded ID matches input's id");
    });
  });

  module('field.Label', function () {
    test('field yields label component', async function (assert) {
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label class="my-label" data-test-label>First Name</field.Label>
          </form.Field>
        </HeadlessForm>
      </template>);

      assert
        .dom('label')
        .hasText('First Name', 'it renders block content')
        .hasClass('my-label', 'it accepts custom HTML classes')
        .hasAttribute(
          'data-test-label',
          '',
          'it accepts arbitrary HTML attributes'
        );
    });

    test('label and input are connected', async function (this: RenderingTestContext, assert) {
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input />
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
        .hasAttribute(
          'for',
          id,
          'label is attached to input by `for` attribute'
        );
    });
  });
});
