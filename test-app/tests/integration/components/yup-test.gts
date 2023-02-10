/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { click, fillIn, render, setupOnerror } from '@ember/test-helpers';
import { module, test } from 'qunit';

import HeadlessForm from 'ember-headless-form/components/headless-form';
import validateYup from '@ember-headless-form/yup/helpers/validate-yup';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';

import { object, string } from 'yup';

module('Integration Component HeadlessForm > yup', function (hooks) {
  setupRenderingTest(hooks);

  interface TestFormData {
    firstName?: string;
    lastName?: string;
  }

  const schema = object({
    firstName: string()
      .required()
      .notOneOf(['Foo'], 'Foo is an invalid firstName!'),
    lastName: string()
      .required()
      .notOneOf(['Foo'], 'Foo is an invalid lastName!'),
  });

  test('onSubmit is not called when validation fails', async function (assert) {
    const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };
    const submitHandler = sinon.spy();

    await render(<template>
      <HeadlessForm
        @data={{data}}
        @validate={{validateYup schema}}
        @onSubmit={{submitHandler}}
        as |form|
      >
        <form.field @name="firstName" as |field|>
          <field.label>First Name</field.label>
          <field.input data-test-first-name />
        </form.field>
        <button type="submit" data-test-submit>Submit</button>
      </HeadlessForm>
    </template>);

    await click('[data-test-submit]');

    assert.false(submitHandler.called, '@onSubmit is not called');
  });

  test('onInvalid is called when validation fails', async function (assert) {
    const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };
    const invalidHandler = sinon.spy();

    await render(<template>
      <HeadlessForm
        @data={{data}}
        @validate={{validateYup schema}}
        @onInvalid={{invalidHandler}}
        as |form|
      >
        <form.field @name="firstName" as |field|>
          <field.label>First Name</field.label>
          <field.input data-test-first-name />
        </form.field>
        <button type="submit" data-test-submit>Submit</button>
      </HeadlessForm>
    </template>);

    await click('[data-test-submit]');

    assert.true(
      invalidHandler.calledWith(data, {
        firstName: [
          {
            type: 'notOneOf',
            value: 'Foo',
            message: 'Foo is an invalid firstName!',
          },
        ],
      }),
      '@onInvalid was called'
    );
  });

  test('onSubmit is called when validation passes', async function (assert) {
    const data: TestFormData = {};
    const submitHandler = sinon.spy();

    await render(<template>
      <HeadlessForm
        @data={{data}}
        @validate={{validateYup schema}}
        @onSubmit={{submitHandler}}
        as |form|
      >
        <form.field @name="firstName" as |field|>
          <field.label>First Name</field.label>
          <field.input data-test-first-name />
        </form.field>
        <form.field @name="lastName" as |field|>
          <field.label>Last Name</field.label>
          <field.input data-test-last-name />
        </form.field>
        <button type="submit" data-test-submit>Submit</button>
      </HeadlessForm>
    </template>);

    await fillIn('input[data-test-first-name]', 'Nicole');
    await fillIn('input[data-test-last-name]', 'Chung');
    await click('[data-test-submit]');

    assert.true(
      submitHandler.calledWith({
        firstName: 'Nicole',
        lastName: 'Chung',
      }),
      '@onSubmit has been called'
    );
  });

  test('validation errors are exposed as field.errors on submit', async function (assert) {
    const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };

    await render(<template>
      <HeadlessForm @data={{data}} @validate={{validateYup schema}} as |form|>
        <form.field @name="firstName" as |field|>
          <field.label>First Name</field.label>
          <field.input data-test-first-name />
          <field.errors data-test-first-name-errors />
        </form.field>
        <form.field @name="lastName" as |field|>
          <field.label>Last Name</field.label>
          <field.input data-test-last-name />
          <field.errors data-test-last-name-errors />
        </form.field>
        <button type="submit" data-test-submit>Submit</button>
      </HeadlessForm>
    </template>);

    assert
      .dom('[data-test-first-name-errors]')
      .doesNotExist(
        'validation errors are not rendered before validation happens'
      );
    assert
      .dom('[data-test-last-name-errors]')
      .doesNotExist(
        'validation errors are not rendered before validation happens'
      );

    await click('[data-test-submit]');

    assert
      .dom('[data-test-first-name-errors]')
      .hasText('Foo is an invalid firstName!');
    assert
      .dom('[data-test-last-name-errors]')
      .doesNotExist(
        'validation errors are not rendered when validation succeeds'
      );
  });

  test('Glint: type error when schema does not match form data', async function (assert) {
    assert.expect(0);
    const data: { foo?: string } = {};
    const submitHandler = sinon.spy();

    await render(<template>
      <HeadlessForm
        @data={{data}}
        {{! @glint-expect-error }}
        @validate={{validateYup schema}}
        @onSubmit={{submitHandler}}
        as |form|
      >
        <form.field @name="foo" as |field|>
          <field.label>First Name</field.label>
          <field.input data-test-first-name />
        </form.field>
        <button type="submit" data-test-submit>Submit</button>
      </HeadlessForm>
    </template>);
  });
});
