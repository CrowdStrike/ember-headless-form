import { module, test } from 'qunit';
import { setupRenderingTest } from 'test-app/tests/helpers';
import {
  fillIn,
  render,
  RenderingTestContext,
  triggerEvent,
} from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';
import type { TestContext } from '@ember/test-helpers';

module('Integration Component headless-form', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders form markup', async function (assert) {
    await render(hbs`<HeadlessForm class="foo" novalidate />`);

    assert.dom('form').exists('it renders as <form>');
    assert
      .dom('form')
      .hasClass('foo', 'it accepts custom HTML classes')
      .hasAttribute('novalidate', '', 'it accepts arbitrary HTML attributes');
  });

  module('form.field', function () {
    test('from yields field component', async function (this: TestContext & {
      data: { firstName?: string };
    }, assert) {
      this.data = { firstName: 'Simon' };

      await render<typeof this>(hbs`
        <HeadlessForm @data={{this.data}} as |form|>
          <form.field @name="firstName">
            <div data-test-user-content>foo</div>
          </form.field>
        </HeadlessForm>
      `);

      assert
        .dom('[data-test-user-content]')
        .exists('form field can render user content');

      assert
        .dom('form > [data-test-user-content]')
        .exists('does not render anything on its own');
    });

    test('Glint: @name argument only expects keys of @data', async function (this: TestContext & {
      data: { firstName?: string };
    }, assert) {
      assert.expect(0);
      this.data = { firstName: 'Simon' };

      await render<typeof this>(hbs`
        <HeadlessForm @data={{this.data}} as |form|>
          {{! @glint-expect-error this is expected to error when running glint checks! }}
          <form.field @name="lastName">
            <div data-test-user-content>foo</div>
          </form.field>
        </HeadlessForm>
      `);
    });
  });

  module('field.label', function () {
    test('field yields label component', async function (this: TestContext & {
      data: { firstName?: string };
    }, assert) {
      this.data = { firstName: 'Simon' };

      await render<typeof this>(hbs`
        <HeadlessForm @data={{this.data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label class="my-label" data-test-label>First Name</field.label>
          </form.field>
        </HeadlessForm>
      `);

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

    test('label and input are connected', async function (this: RenderingTestContext & {
      data: { firstName?: string };
    }, assert) {
      this.data = { firstName: 'Simon' };

      await render<typeof this>(hbs`
        <HeadlessForm @data={{this.data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label>First Name</field.label>
            <field.input/>
          </form.field>
        </HeadlessForm>
      `);

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
    test('field yields input component', async function (this: TestContext & {
      data: { firstName?: string };
    }, assert) {
      this.data = { firstName: 'Simon' };

      await render<typeof this>(hbs`
        <HeadlessForm @data={{this.data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.input class="my-input" data-test-input/>
          </form.field>
        </HeadlessForm>
      `);

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

    test('input accepts all supported types', async function (this: TestContext & {
      data: { firstName?: string };
      type:
        | 'color'
        | 'date'
        | 'datetime-local'
        | 'email'
        | 'hidden'
        | 'month'
        | 'number'
        | 'password'
        | 'range'
        | 'search'
        | 'tel'
        | 'text'
        | 'time'
        | 'url'
        | 'week';
    }, assert) {
      this.data = { firstName: 'Simon' };

      await render<typeof this>(hbs`
        <HeadlessForm @data={{this.data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.input @type={{this.type}} />
          </form.field>
        </HeadlessForm>
      `);

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
        this.set('type', type);

        assert.dom('input').hasAttribute('type', type, `supports type=${type}`);
      }
    });
  });

  module('data', function () {
    test('data is passed to form controls', async function (this: RenderingTestContext & {
      data: { firstName?: string; lastName?: string };
    }, assert) {
      this.data = { firstName: 'Tony', lastName: 'Ward' };

      await render<typeof this>(hbs`
        <HeadlessForm @data={{this.data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label>First Name</field.label>
            <field.input data-test-first-name/>
          </form.field>
          <form.field @name="lastName" as |field|>
          <field.label>Last Name</field.label>
          <field.input data-test-last-name/>
        </form.field>
        </HeadlessForm>
      `);

      assert.dom('input[data-test-first-name]').hasValue('Tony');
      assert.dom('input[data-test-last-name]').hasValue('Ward');
    });

    test('data is not mutated', async function (this: RenderingTestContext & {
      data: { firstName?: string; lastName?: string };
    }, assert) {
      this.data = { firstName: 'Tony', lastName: 'Ward' };

      await render<typeof this>(hbs`
        <HeadlessForm @data={{this.data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label>First Name</field.label>
            <field.input data-test-first-name/>
          </form.field>
          <form.field @name="lastName" as |field|>
          <field.label>Last Name</field.label>
          <field.input data-test-last-name/>
        </form.field>
        </HeadlessForm>
      `);

      await fillIn('input[data-test-first-name]', 'Preston');
      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.strictEqual(
        this.data.firstName,
        'Tony',
        'data object is not mutated after entering data'
      );

      await triggerEvent('form', 'submit');
      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.strictEqual(
        this.data.firstName,
        'Tony',
        'data object is not mutated after submitting'
      );
    });
  });
});
