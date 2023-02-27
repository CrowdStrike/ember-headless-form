/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { tracked } from '@glimmer/tracking';
import {
  blur,
  click,
  fillIn,
  render,
  rerender,
  waitFor,
} from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { RenderingTestContext } from '@ember/test-helpers';
import type {
  FormValidateCallback,
  FieldValidateCallback,
  ErrorRecord,
  ValidationError,
} from 'ember-headless-form';

import { input } from '../../helpers/dom';

module('Integration Component HeadlessForm > Async state', function (hooks) {
  setupRenderingTest(hooks);

  interface TestFormData {
    firstName?: string;
    lastName?: string;
  }

  const validateFieldCallbackSync: FieldValidateCallback<TestFormData> = (
    value,
    field
  ) => {
    const errors = [];
    if (value == undefined) {
      errors.push({
        type: 'required',
        value,
        message: `${field} is required!`,
      });
    } else {
      if (value.charAt(0).toUpperCase() !== value.charAt(0)) {
        errors.push({
          type: 'uppercase',
          value,
          message: `${field} must be upper case!`,
        });
      }

      if (value.toLowerCase() === 'foo') {
        errors.push({
          type: 'notFoo',
          value,
          message: `Foo is an invalid ${field}!`,
        });
      }
    }

    return errors.length > 0 ? errors : undefined;
  };

  const validateFieldCallbackAsync: FieldValidateCallback<
    TestFormData
  > = async (value, field, data) => {
    // intentionally adding a delay here, to make the validation behave truly async and assert that we are correctly waiting for it in tests
    await new Promise((resolve) => setTimeout(resolve, 10));
    return validateFieldCallbackSync(value, field, data);
  };

  const stringify = (data: unknown) => JSON.stringify(data);

  module('validation', function () {
    test('validation state is yielded - valid', async function (assert) {
      const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field
            @name="firstName"
            @validate={{validateFieldCallbackAsync}}
            as |field|
          >
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          {{#if form.validationState}}
            <div data-test-validation-state>{{form.validationState.state}}</div>
            {{#if form.validationState.isResolved}}
              <div data-test-validation-value>
                {{stringify form.validationState.value}}
              </div>
            {{/if}}
          {{/if}}
        </HeadlessForm>
      </template>);

      assert
        .dom('[data-test-validation-state]')
        .doesNotExist('form.validation is not present until first validation');

      const promise = click('[data-test-submit]');
      await waitFor('[data-test-validation-state]');

      assert
        .dom('[data-test-validation-state]')
        .hasText('PENDING', 'form.validation is pending');

      await promise;

      assert
        .dom('[data-test-validation-state]')
        .hasText('RESOLVED', 'form.validation has resolved');
      assert
        .dom('[data-test-validation-value]')
        .hasText('{}', 'validationState.value has no errors');
    });

    test('validation state is yielded - invalid', async function (assert) {
      const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field
            @name="firstName"
            @validate={{validateFieldCallbackAsync}}
            as |field|
          >
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          {{#if form.validationState}}
            <div data-test-validation-state>{{form.validationState.state}}</div>
            {{#if form.validationState.isResolved}}
              <div data-test-validation-value>
                {{stringify form.validationState.value}}
              </div>
            {{/if}}
          {{/if}}
        </HeadlessForm>
      </template>);

      assert
        .dom('[data-test-validation-state]')
        .doesNotExist('form.validation is not present until first validation');

      const promise = click('[data-test-submit]');
      await waitFor('[data-test-validation-state]');

      assert
        .dom('[data-test-validation-state]')
        .hasText('PENDING', 'form.validation is pending');

      await promise;

      assert
        .dom('[data-test-validation-state]')
        .hasText('RESOLVED', 'form.validation has resolved');
      assert
        .dom('[data-test-validation-value]')
        .hasText(
          '{"firstName":[{"type":"notFoo","value":"Foo","message":"Foo is an invalid firstName!"}]}',
          'validationState.value has ErrorRecord'
        );
    });
  });
});
