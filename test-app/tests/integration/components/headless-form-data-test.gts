/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import {
  click,
  fillIn,
  render,
  rerender,
  triggerEvent,
} from '@ember/test-helpers';
import { module, skip, test } from 'qunit';

import { HeadlessForm } from '@crowdstrike/ember-headless-form';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';

module('Integration Component HeadlessForm > Data', function (hooks) {
  setupRenderingTest(hooks);

  module('data down', function () {
    test('data is passed to form controls', async function (assert) {
      const data = {
        firstName: 'Tony',
        lastName: 'Ward',
        gender: 'male',
        comments: 'lorem ipsum',
        acceptTerms: true,
      };

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
          <form.Field @name="gender" as |field|>
            <field.Radio @value="male" as |radio|>
              <radio.Input data-test-gender-male />
              <radio.Label>Male</radio.Label>
            </field.Radio>
            <field.Radio @value="female" as |radio|>
              <radio.Input data-test-gender-female />
              <radio.Label>Female</radio.Label>
            </field.Radio>
            <field.Radio @value="other" as |radio|>
              <radio.Input data-test-gender-other />
              <radio.Label>Other</radio.Label>
            </field.Radio>
          </form.Field>
          <form.Field @name="comments" as |field|>
            <field.Label>Comments</field.Label>
            <field.Textarea data-test-comments />
          </form.Field>
          <form.Field @name="acceptTerms" as |field|>
            <field.Label>Terms accepted</field.Label>
            <field.Checkbox data-test-terms />
          </form.Field>
        </HeadlessForm>
      </template>);

      assert.dom('input[data-test-first-name]').hasValue('Tony');
      assert.dom('input[data-test-last-name]').hasValue('Ward');
      assert.dom('input[data-test-gender-male]').isChecked();
      assert.dom('input[data-test-gender-female]').isNotChecked();
      assert.dom('input[data-test-gender-other]').isNotChecked();
      assert.dom('textarea[data-test-comments]').hasValue('lorem ipsum');
      assert.dom('input[data-test-terms]').isChecked();
    });

    test('value is yielded from field component', async function (assert) {
      const data = { firstName: 'Tony', lastName: 'Ward' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <div data-test-first-name>{{field.value}}</div>
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <div data-test-last-name>{{field.value}}</div>
          </form.Field>
        </HeadlessForm>
      </template>);

      assert.dom('[data-test-first-name]').hasText('Tony');
      assert.dom('[data-test-last-name]').hasText('Ward');
    });

    skip('form controls are reactive to data updates', async function (assert) {
      class DummyData {
        @tracked
        firstName = 'Tony';

        @tracked
        lastName = 'Ward';
      }
      const data = new DummyData();

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
        </HeadlessForm>
      </template>);

      assert.dom('input[data-test-first-name]').hasValue('Tony');
      assert.dom('input[data-test-last-name]').hasValue('Ward');

      data.firstName = 'Preston';
      data.lastName = 'Sego';

      await rerender();

      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.dom('input[data-test-last-name]').hasValue('Sego');
    });

    test('data is not mutated', async function (assert) {
      const data = { firstName: 'Tony', lastName: 'Ward' };

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
        </HeadlessForm>
      </template>);

      await fillIn('input[data-test-first-name]', 'Preston');
      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.strictEqual(
        data.firstName,
        'Tony',
        'data object is not mutated after entering data'
      );

      await triggerEvent('form', 'submit');
      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.strictEqual(
        data.firstName,
        'Tony',
        'data object is not mutated after submitting'
      );
    });
  });
  module('actions up', function () {
    test('onSubmit is called with user data', async function (assert) {
      const data = {
        firstName: 'Tony',
        lastName: 'Ward',
        gender: 'male',
        comments: 'lorem ipsum',
        acceptTerms: false,
      };
      const submitHandler = sinon.spy();

      await render(<template>
        <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <field.Label>Last Name</field.Label>
            <field.Input data-test-last-name />
          </form.Field>
          <form.Field @name="gender" as |field|>
            <field.Radio @value="male" as |radio|>
              <radio.Input data-test-gender-male />
              <radio.Label>Male</radio.Label>
            </field.Radio>
            <field.Radio @value="female" as |radio|>
              <radio.Input data-test-gender-female />
              <radio.Label>Female</radio.Label>
            </field.Radio>
            <field.Radio @value="other" as |radio|>
              <radio.Input data-test-gender-other />
              <radio.Label>Other</radio.Label>
            </field.Radio>
          </form.Field>
          <form.Field @name="comments" as |field|>
            <field.Label>Comments</field.Label>
            <field.Textarea data-test-comments />
          </form.Field>
          <form.Field @name="acceptTerms" as |field|>
            <field.Label>Terms accepted</field.Label>
            <field.Checkbox data-test-terms />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      assert.dom('input[data-test-first-name]').hasValue('Tony');
      assert.dom('input[data-test-last-name]').hasValue('Ward');
      assert.dom('textarea[data-test-comments]').hasValue('lorem ipsum');
      assert.dom('input[data-test-terms]').isNotChecked();

      await fillIn('input[data-test-first-name]', 'Nicole');
      await fillIn('input[data-test-last-name]', 'Chung');
      await click('input[data-test-gender-female]');
      await fillIn('textarea[data-test-comments]', 'foo bar');
      await click('input[data-test-terms]');
      await click('[data-test-submit]');

      assert.deepEqual(
        data,
        {
          firstName: 'Tony',
          lastName: 'Ward',
          gender: 'male',
          comments: 'lorem ipsum',
          acceptTerms: false,
        },
        'original data is not mutated'
      );

      assert.true(
        submitHandler.calledWith({
          firstName: 'Nicole',
          lastName: 'Chung',
          gender: 'female',
          comments: 'foo bar',
          acceptTerms: true,
        }),
        'new data is passed to submit handler'
      );
    });

    test('setValue yielded from field sets internal value', async function (assert) {
      const data = { firstName: 'Tony' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <label for="first-name">First name:</label>
            <input
              type="text"
              value={{field.value}}
              id="first-name"
              data-test-first-name
            />
            <button
              type="button"
              {{on "click" (fn field.setValue "Nicole")}}
              data-test-custom-control
            >
              Update
            </button>
          </form.Field>
        </HeadlessForm>
      </template>);

      assert.dom('input[data-test-first-name]').hasValue('Tony');

      await click('[data-test-custom-control]');

      assert.deepEqual(data, { firstName: 'Tony' }, 'data is not mutated');

      assert.dom('input[data-test-first-name]').hasValue('Nicole');
    });
  });
  module('@dataMode="mutable"', function () {
    test('mutates passed @data when form fields are updated', async function (assert) {
      const data = { firstName: 'Tony', lastName: 'Ward' };

      await render(<template>
        <HeadlessForm @data={{data}} @dataMode="mutable" as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <field.Label>Last Name</field.Label>
            <field.Input data-test-last-name />
          </form.Field>
        </HeadlessForm>
      </template>);

      await fillIn('input[data-test-first-name]', 'Preston');
      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.strictEqual(
        data.firstName,
        'Preston',
        'data object is mutated after entering data'
      );
    });

    test('@onSubmit is called with same instance of @data', async function (assert) {
      const data = { firstName: 'Tony', lastName: 'Ward' };
      const submitHandler = sinon.spy();

      await render(<template>
        <HeadlessForm
          @data={{data}}
          @dataMode="mutable"
          @onSubmit={{submitHandler}}
          as |form|
        >
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <field.Label>Last Name</field.Label>
            <field.Input data-test-last-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      await fillIn('input[data-test-first-name]', 'Preston');
      await click('[data-test-submit]');

      assert.strictEqual(
        submitHandler.firstCall.firstArg,
        data,
        '@OnSubmit is called with same instance of @data, not a copy'
      );
    });
  });
});
