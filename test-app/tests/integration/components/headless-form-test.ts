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
    assert.dom('form').hasClass('foo').hasAttribute('novalidate');
  });

  test('it yields field component', async function (this: TestContext & {
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
});
