/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

module('Integration Component HeadlessForm > Textarea', function (hooks) {
  setupRenderingTest(hooks);

  test('field yields textarea component', async function (assert) {
    const data: { comment?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="comment" as |field|>
          <field.Textarea class="my-textarea" data-test-textarea />
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('textarea')
      .exists('render a textarea')
      .hasAttribute('name', 'comment')
      .hasClass('my-textarea', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-textarea',
        '',
        'it accepts arbitrary HTML attributes'
      );
  });
});
