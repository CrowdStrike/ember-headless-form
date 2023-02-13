import { render } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';
import { module, test } from 'qunit';

import { setupRenderingTest } from 'test-app/tests/helpers';

module('Integration Component HeadlessForm', function (hooks) {
  setupRenderingTest(hooks);

  // This is just a smoke test to make sure that our app re-export works for classic apps not using template-imports, as all our other tests use template-imports
  test('it renders', async function (assert) {
    await render(hbs`<HeadlessForm />`);

    assert.dom('form').exists();
  });
});
