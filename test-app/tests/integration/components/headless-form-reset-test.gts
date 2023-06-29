/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { on } from '@ember/modifier';
import { click, fillIn, render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

interface TestFormData {
  firstName?: string;
  lastName?: string;
}

module('Integration Component HeadlessForm > Reset', function (hooks) {
  setupRenderingTest(hooks);

  module('reset button', function () {
    test('dirty fields are resetted', async function (assert) {
      const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <field.Label>Last Name</field.Label>
            <field.Input data-test-last-name />
          </form.Field>
          <button type="reset" data-test-reset>Reset</button>
        </HeadlessForm>
      </template>);

      await fillIn('[data-test-first-name]', 'Nicole');
      await click('[data-test-reset]');

      assert.dom('[data-test-first-name]').hasValue('Tony');
      assert.dom('[data-test-last-name]').hasValue('Ward');
    });

    test('validation errors are cleared', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
            <field.Errors data-test-first-name-errors />
            {{#if field.isInvalid}}
              <div data-test-invalid />
            {{/if}}
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <field.Label>Last Name</field.Label>
            <field.Input data-test-last-name />
            <field.Errors data-test-last-name-errors />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          <button type="reset" data-test-reset>Reset</button>
        </HeadlessForm>
      </template>);

      await click('[data-test-submit]');

      assert
        .dom('[data-test-first-name-errors]')
        .exists({ count: 1 }, 'validation errors appear when validation fails');
      assert.dom('[data-test-first-name]').hasAria('invalid', 'true');
      assert.dom('[data-test-invalid]').exists();

      await click('[data-test-reset]');

      assert
        .dom('[data-test-first-name-errors]')
        .doesNotExist('validation errors are removed on reset');
      assert.dom('[data-test-first-name]').doesNotHaveAria('invalid');
      assert.dom('[data-test-invalid]').doesNotExist();
    });

    test('validation state is resetted', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          <button type="reset" data-test-reset>Reset</button>
          {{#if form.validationState}}
            <div data-test-validation-state>{{form.validationState.state}}</div>
          {{/if}}
        </HeadlessForm>
      </template>);

      assert
        .dom('[data-test-validation-state]')
        .doesNotExist(
          'form.validationState is not present until first validation'
        );

      await click('[data-test-submit]');

      assert
        .dom('[data-test-validation-state]')
        .hasText('RESOLVED', 'form.validationState has resolved');

      await click('[data-test-reset]');

      assert
        .dom('[data-test-validation-state]')
        .doesNotExist('form.validationState is resetted');
    });

    test('submission state is resetted', async function (assert) {
      const data: TestFormData = {};
      const submitHandler = () => 'ok';

      await render(<template>
        <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          <button type="reset" data-test-reset>Reset</button>
          {{#if form.submissionState}}
            <div data-test-submission-state>{{form.submissionState.state}}</div>
          {{/if}}
        </HeadlessForm>
      </template>);

      assert
        .dom('[data-test-submission-state]')
        .doesNotExist(
          'form.submissionState is not present until first validation'
        );

      await click('[data-test-submit]');

      assert
        .dom('[data-test-submission-state]')
        .hasText('RESOLVED', 'form.submissionState has resolved');

      await click('[data-test-reset]');

      assert
        .dom('[data-test-submission-state]')
        .doesNotExist('form.submissionState is resetted');
    });
  });

  module('reset action', function () {
    test('dirty fields are resetted', async function (assert) {
      const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <field.Label>Last Name</field.Label>
            <field.Input data-test-last-name />
          </form.Field>
          <button
            type="button"
            {{on "click" form.reset}}
            data-test-reset
          >Reset</button>
        </HeadlessForm>
      </template>);

      await fillIn('[data-test-first-name]', 'Nicole');
      await click('[data-test-reset]');

      assert.dom('[data-test-first-name]').hasValue('Tony');
      assert.dom('[data-test-last-name]').hasValue('Ward');
    });

    test('validation errors are cleared', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
            <field.Errors data-test-first-name-errors />
            {{#if field.isInvalid}}
              <div data-test-invalid />
            {{/if}}
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <field.Label>Last Name</field.Label>
            <field.Input data-test-last-name />
            <field.Errors data-test-last-name-errors />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          <button
            type="button"
            {{on "click" form.reset}}
            data-test-reset
          >Reset</button>
        </HeadlessForm>
      </template>);

      await click('[data-test-submit]');

      assert
        .dom('[data-test-first-name-errors]')
        .exists({ count: 1 }, 'validation errors appear when validation fails');
      assert.dom('[data-test-first-name]').hasAria('invalid', 'true');
      assert.dom('[data-test-invalid]').exists();

      await click('[data-test-reset]');

      assert
        .dom('[data-test-first-name-errors]')
        .doesNotExist('validation errors are removed on reset');
      assert.dom('[data-test-first-name]').doesNotHaveAria('invalid');
      assert.dom('[data-test-invalid]').doesNotExist();
    });

    test('validation state is resetted', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          <button
            type="button"
            {{on "click" form.reset}}
            data-test-reset
          >Reset</button>
          {{#if form.validationState}}
            <div data-test-validation-state>{{form.validationState.state}}</div>
          {{/if}}
        </HeadlessForm>
      </template>);

      assert
        .dom('[data-test-validation-state]')
        .doesNotExist(
          'form.validationState is not present until first validation'
        );

      await click('[data-test-submit]');

      assert
        .dom('[data-test-validation-state]')
        .hasText('RESOLVED', 'form.validationState has resolved');

      await click('[data-test-reset]');

      assert
        .dom('[data-test-validation-state]')
        .doesNotExist('form.validationState is resetted');
    });

    test('submission state is resetted', async function (assert) {
      const data: TestFormData = {};
      const submitHandler = () => 'ok';

      await render(<template>
        <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          <button
            type="button"
            {{on "click" form.reset}}
            data-test-reset
          >Reset</button>
          {{#if form.submissionState}}
            <div data-test-submission-state>{{form.submissionState.state}}</div>
          {{/if}}
        </HeadlessForm>
      </template>);

      assert
        .dom('[data-test-submission-state]')
        .doesNotExist(
          'form.submissionState is not present until first validation'
        );

      await click('[data-test-submit]');

      assert
        .dom('[data-test-submission-state]')
        .hasText('RESOLVED', 'form.submissionState has resolved');

      await click('[data-test-reset]');

      assert
        .dom('[data-test-submission-state]')
        .doesNotExist('form.submissionState is resetted');
    });
  });
});
