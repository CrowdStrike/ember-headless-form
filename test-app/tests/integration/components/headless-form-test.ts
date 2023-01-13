import { module, test } from 'qunit';
import { setupRenderingTest } from 'test-app/tests/helpers';
import { render } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';
import type { TestContext } from '@ember/test-helpers';

module('Integration | Component | headless-form', function (hooks) {
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
  });
});
