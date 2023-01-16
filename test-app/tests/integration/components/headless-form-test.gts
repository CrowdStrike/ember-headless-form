import { fillIn, render, triggerEvent } from '@ember/test-helpers';
import { module, test } from 'qunit';

import HeadlessForm from 'ember-headless-form/components/headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';


module('Integration Component headless-form', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders form markup', async function (assert) {
    await render(
      <template>
        <HeadlessForm class="foo" novalidate />
      </template>
    );

    assert.dom('form').exists('it renders as <form>');
    assert
      .dom('form')
      .hasClass('foo', 'it accepts custom HTML classes')
      .hasAttribute('novalidate', '', 'it accepts arbitrary HTML attributes');
  });

  module('form.field', function () {
    test('form yields field component', async function (assert) {
      const data = { firstName: 'Simon' };

      await render(
        <template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName">
            <div data-test-user-content>foo</div>
          </form.field>
        </HeadlessForm>
        </template>
      );

      assert
        .dom('[data-test-user-content]')
        .exists('form field can render user content');

      assert
        .dom('form > [data-test-user-content]')
        .exists('does not render anything on its own');
    });

    test('Glint: @name argument only expects keys of @data', async function (assert) {
      assert.expect(0);
      const data = { firstName: 'Simon' };

      await render(
        <template>
        <HeadlessForm @data={{data}} as |form|>
          {{! @glint-expect-error this is expected to error when running glint checks! }}
          <form.field @name="lastName">
            <div data-test-user-content>foo</div>
          </form.field>
        </HeadlessForm>
        </template>
      );
    });
  });

  module('field.label', function () {
    test('field yields label component', async function (assert) {
      const data = { firstName: 'Simon' };

      await render(
        <template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label class="my-label" data-test-label>First Name</field.label>
          </form.field>
        </HeadlessForm>
        </template>
      );

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

    test('label and input are connected', async function (assert) {
      const data = { firstName: 'Simon' };

      await render(
        <template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label>First Name</field.label>
            <field.input/>
          </form.field>
        </HeadlessForm>
        </template>
      );

      assert.dom('input').hasAttribute(
        'id',
        // copied from https://ihateregex.io/expr/uuid/
        /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/,
        'input has id with dynamically generated uuid'
      );

      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      const id = this.element.querySelector('input')!.id;

      assert
        .dom('label')
        .hasAttribute(
          'for',
          id,
          'label is attached to input by `for` attribute'
        );
    });
  });

  module('field.input', function () {
    test('field yields input component', async function (assert) {
      const data = { firstName: 'Simon' };

      await render(
        <template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.input class="my-input" data-test-input/>
          </form.field>
        </HeadlessForm>
        </template>
      );

      assert
        .dom('input')
        .exists('render an input')
        .hasClass('my-input', 'it accepts custom HTML classes')
        .hasAttribute(
          'data-test-input',
          '',
          'it accepts arbitrary HTML attributes'
        );
    });

    test('input accepts all supported types', async function (assert) {
      const data = { firstName: 'Simon' };

      for (const type of [
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
      ]) {
              await render(
        <template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.input @type={{type}} />
          </form.field>
        </HeadlessForm>
        </template>
      );

        assert.dom('input').hasAttribute('type', type, `supports type=${type}`);
      }
    });
  });

  module('data', function () {
    test('data is passed to form controls', async function (assert) {
      const data = { firstName: 'Tony', lastName: 'Ward' };

      await render(
        <template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label>First Name</field.label>
            <field.input data-test-first-name/>
          </form.field>
          <form.field @name="lastName" as |field|>
          <field.label>Last Name</field.label>
          <field.input data-test-last-name/>
        </form.field>
        </HeadlessForm>
        </template>
      );

      assert.dom('input[data-test-first-name]').hasValue('Tony');
      assert.dom('input[data-test-last-name]').hasValue('Ward');
    });

    test('data is not mutated', async function (assert) {
      const data = { firstName: 'Tony', lastName: 'Ward' };

      await render(
        <template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label>First Name</field.label>
            <field.input data-test-first-name/>
          </form.field>
          <form.field @name="lastName" as |field|>
          <field.label>Last Name</field.label>
          <field.input data-test-last-name/>
        </form.field>
        </HeadlessForm>
        </template>
      );

      await fillIn('input[data-test-first-name]', 'Preston');
      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.strictEqual(
        data.firstName,
        'Tony',
        'data object is not mutated after entering data'
      );

      await triggerEvent('form', 'submit');
      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.strictEqual(
        data.firstName,
        'Tony',
        'data object is not mutated after submitting'
      );
    });
  });

});
