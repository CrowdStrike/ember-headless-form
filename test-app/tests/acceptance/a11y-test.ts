import { click, visit } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { setupApplicationTest } from 'test-app/tests/helpers';

import { a11yAudit } from 'ember-a11y-testing/test-support';

module('Acceptance | a11y', function (hooks) {
  setupApplicationTest(hooks);

  test('form passes a11y audit', async function (assert) {
    await visit('/');

    await a11yAudit();
    assert.true(true, 'no a11y errors found!');
  });

  test('form passes a11y audit after validation', async function (assert) {
    await visit('/');
    await click('[data-test-submit]');

    await a11yAudit();
    assert.true(true, 'no a11y errors found!');
  });
});
