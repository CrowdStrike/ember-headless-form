/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { click, fillIn, render, setupOnerror } from '@ember/test-helpers';
import { module, test, skip } from 'qunit';

import HeadlessForm from 'ember-headless-form/components/headless-form';
import validateChangeset from '@ember-headless-form/changeset/helpers/validate-changeset';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';
import { Changeset } from 'ember-changeset';

import type { ValidatorAction } from 'ember-changeset/types';

module('Integration Component HeadlessForm > Changeset', function (hooks) {
  setupRenderingTest(hooks);

  interface TestFormData {
    firstName?: string;
    lastName?: string;
  }

  const validator: ValidatorAction = ({ key, newValue }) => {
    const errors: string[] = [];

    if (newValue == undefined) {
      errors.push(`${key} is required!`);
    } else if (typeof newValue !== 'string') {
      errors.push('Unexpected type');
    } else {
      if (newValue.charAt(0).toUpperCase() !== newValue.charAt(0)) {
        errors.push(`${key} must be upper case!`);
      }

      if (newValue.toLowerCase() === 'foo') {
        errors.push(`Foo is an invalid ${key}!`);
      }
    }

    return errors.length > 0 ? errors : true;
  };

  // Could not get this test to work, setupOnerror does not catch the error as expected here
  skip('throws error when validating and data is no changeset', async function (assert) {
    assert.expect(1);
    setupOnerror((e: Error) => {
      assert.strictEqual(
        e.message,
        'Assertion Failed: Cannot use `validateChangeset` on `@data` that is not a Changeset instance!',
        'Expected assertion error message'
      );
    });

    const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };
    const submitHandler = sinon.spy();

    await render(<template>
      <HeadlessForm
        @data={{data}}
        @dataMode="mutable"
        {{! @glint-expect-error --  a type error is expected here, as this test intentionally has a type mismatch when data not being a changeset }}
        @validate={{validateChangeset}}
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
  });

  test('onSubmit is not called when validation fails', async function (assert) {
    const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };
    const changeset = Changeset(data, validator);
    const submitHandler = sinon.spy();

    await render(<template>
      <HeadlessForm
        @data={{changeset}}
        @dataMode="mutable"
        @validate={{validateChangeset}}
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
    const changeset = Changeset(data, validator);
    const invalidHandler = sinon.spy();

    await render(<template>
      <HeadlessForm
        @data={{changeset}}
        @dataMode="mutable"
        @validate={{validateChangeset}}
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
      invalidHandler.calledWith(changeset, {
        firstName: [
          {
            type: 'changeset',
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
    const changeset = Changeset(data, validator);
    const submitHandler = sinon.spy();

    await render(<template>
      <HeadlessForm
        @data={{changeset}}
        @dataMode="mutable"
        @validate={{validateChangeset}}
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
      submitHandler.calledWith(changeset),
      '@onSubmit has been called'
    );
  });

  test('validation errors are exposed as field.errors on submit', async function (assert) {
    const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };
    const changeset = Changeset(data, validator);

    await render(<template>
      <HeadlessForm
        @data={{changeset}}
        @dataMode="mutable"
        @validate={{validateChangeset}}
        as |form|
      >
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
});
