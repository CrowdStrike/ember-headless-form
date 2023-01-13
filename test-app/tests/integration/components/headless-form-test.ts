import { module, test } from 'qunit';
import { setupRenderingTest } from 'test-app/tests/helpers';
import { render } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';

module('Integration | Component | headless-form', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders form markup', async function (assert) {
    await render(hbs`<HeadlessForm class="foo" novalidate />`);

    assert.dom('form').exists('it renders as <form>');
    assert.dom('form').hasClass('foo').hasAttribute('novalidate');
  });
});
