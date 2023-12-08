/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import {
  click,
  fillIn,
  render,
  rerender,
  select,
  triggerEvent,
} from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type Store from '@ember-data/store';

module('Integration Component HeadlessForm > Data', function (hooks) {
  setupRenderingTest(hooks);

  module('data down', function () {
    module('data is passed to form controls', function () {
      test('POJO', async function (assert) {
        const data = {
          firstName: 'Tony',
          lastName: 'Ward',
          gender: 'male',
          country: 'USA',
          comments: 'lorem ipsum',
          acceptTerms: true,
          age: 21,
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
              <field.RadioGroup as |group|>
                <group.Radio @value="male" as |radio|>
                  <radio.Input data-test-gender-male />
                  <radio.Label>Male</radio.Label>
                </group.Radio>
                <group.Radio @value="female" as |radio|>
                  <radio.Input data-test-gender-female />
                  <radio.Label>Female</radio.Label>
                </group.Radio>
                <group.Radio @value="other" as |radio|>
                  <radio.Input data-test-gender-other />
                  <radio.Label>Other</radio.Label>
                </group.Radio>
              </field.RadioGroup>
            </form.Field>
            <form.Field @name="age" as |field|>
              <field.Label>Age</field.Label>
              <field.Input @type="number" data-test-age />
            </form.Field>
            <form.Field @name="country" as |field|>
              <field.Label>Country</field.Label>
              <field.Select data-test-country as |select|>
                <select.Option @value="USA">United States</select.Option>
                <select.Option @value="GER">Germany</select.Option>
              </field.Select>
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
        assert.dom('input[data-test-age]').hasValue('21');
        assert.dom('select[data-test-country]').hasValue('USA');
        assert.dom('textarea[data-test-comments]').hasValue('lorem ipsum');
        assert.dom('input[data-test-terms]').isChecked();
      });

      test('class object', async function (assert) {
        class MyData {
          constructor(public firstName: string, public lastName: string, public gender: 'male' | 'female' | 'other', public country: string, public comments: string, public acceptTerms: boolean, public age: number) {}
        }

        const data = new MyData(
          'Tony',
          'Ward',
          'male',
          'USA',
          'lorem ipsum',
          true,
          21,
        );

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
              <field.RadioGroup as |group|>
                <group.Radio @value="male" as |radio|>
                  <radio.Input data-test-gender-male />
                  <radio.Label>Male</radio.Label>
                </group.Radio>
                <group.Radio @value="female" as |radio|>
                  <radio.Input data-test-gender-female />
                  <radio.Label>Female</radio.Label>
                </group.Radio>
                <group.Radio @value="other" as |radio|>
                  <radio.Input data-test-gender-other />
                  <radio.Label>Other</radio.Label>
                </group.Radio>
              </field.RadioGroup>
            </form.Field>
            <form.Field @name="age" as |field|>
              <field.Label>Age</field.Label>
              <field.Input @type="number" data-test-age />
            </form.Field>
            <form.Field @name="country" as |field|>
              <field.Label>Country</field.Label>
              <field.Select data-test-country as |select|>
                <select.Option @value="USA">United States</select.Option>
                <select.Option @value="GER">Germany</select.Option>
              </field.Select>
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
        assert.dom('input[data-test-age]').hasValue('21');
        assert.dom('select[data-test-country]').hasValue('USA');
        assert.dom('textarea[data-test-comments]').hasValue('lorem ipsum');
        assert.dom('input[data-test-terms]').isChecked();
      });

      test('ember-data object', async function (assert) {
        const store = this.owner.lookup('service:store') as Store;

        const data = store.createRecord('user', {
          firstName: 'Tony',
          lastName: 'Ward',
          gender: 'male',
          country: 'USA',
          comments: 'lorem ipsum',
          acceptTerms: true,
          age: 21,
        });

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
              <field.RadioGroup as |group|>
                <group.Radio @value="male" as |radio|>
                  <radio.Input data-test-gender-male />
                  <radio.Label>Male</radio.Label>
                </group.Radio>
                <group.Radio @value="female" as |radio|>
                  <radio.Input data-test-gender-female />
                  <radio.Label>Female</radio.Label>
                </group.Radio>
                <group.Radio @value="other" as |radio|>
                  <radio.Input data-test-gender-other />
                  <radio.Label>Other</radio.Label>
                </group.Radio>
              </field.RadioGroup>
            </form.Field>
            <form.Field @name="age" as |field|>
              <field.Label>Age</field.Label>
              <field.Input @type="number" data-test-age />
            </form.Field>
            <form.Field @name="country" as |field|>
              <field.Label>Country</field.Label>
              <field.Select data-test-country as |select|>
                <select.Option @value="USA">United States</select.Option>
                <select.Option @value="GER">Germany</select.Option>
              </field.Select>
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
        assert.dom('input[data-test-age]').hasValue('21');
        assert.dom('select[data-test-country]').hasValue('USA');
        assert.dom('textarea[data-test-comments]').hasValue('lorem ipsum');
        assert.dom('input[data-test-terms]').isChecked();
      });
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

    test('form controls are reactive to updating data', async function (assert) {
      interface Data {
        firstName: string;
        lastName: string;
      }
      class Context {
        @tracked data?: Data;
      }

      const ctx = new Context();

      ctx.data = { firstName: 'Tony', lastName: 'Ward' };

      await render(<template>
        <HeadlessForm @data={{ctx.data}} as |form|>
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

      ctx.data = { firstName: 'Preston', lastName: 'Sego' };

      await rerender();

      assert.dom('input[data-test-first-name]').hasValue('Preston');
      assert.dom('input[data-test-last-name]').hasValue('Sego');
    });

    test('form controls are reactive to updating data properties', async function (assert) {
      class DummyData {
        @tracked firstName = 'Tony';

        @tracked lastName = 'Ward';
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

    test('form controls keep dirty state when updating data properties', async function (assert) {
      class DummyData {
        @tracked firstName = 'Tony';

        @tracked lastName = 'Ward';
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

      await fillIn('input[data-test-first-name]', 'Simon');

      data.firstName = 'Preston';
      data.lastName = 'Sego';

      await rerender();

      assert.dom('input[data-test-first-name]').hasValue('Simon');
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
    module('onSubmit is called with user data', function() {
      test('POJO', async function (assert) {
        const data = {
          firstName: 'Tony',
          lastName: 'Ward',
          gender: 'male',
          country: 'USA',
          comments: 'lorem ipsum',
          acceptTerms: false,
          age: 21,
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
              <field.RadioGroup as |group|>
                <group.Radio @value="male" as |radio|>
                  <radio.Input data-test-gender-male />
                  <radio.Label>Male</radio.Label>
                </group.Radio>
                <group.Radio @value="female" as |radio|>
                  <radio.Input data-test-gender-female />
                  <radio.Label>Female</radio.Label>
                </group.Radio>
                <group.Radio @value="other" as |radio|>
                  <radio.Input data-test-gender-other />
                  <radio.Label>Other</radio.Label>
                </group.Radio>
              </field.RadioGroup>
            </form.Field>
            <form.Field @name="age" as |field|>
              <field.Label>Age</field.Label>
              <field.Input @type="number" data-test-age />
            </form.Field>
            <form.Field @name="country" as |field|>
              <field.Label>Country</field.Label>
              <field.Select data-test-country as |select|>
                <select.Option @value="USA">United States</select.Option>
                <select.Option @value="CA">Canada</select.Option>
              </field.Select>
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
        await select('select[data-test-country]', 'CA');
        await click('input[data-test-gender-female]');
        await fillIn('input[data-test-age]', '20');
        await fillIn('textarea[data-test-comments]', 'foo bar');
        await click('input[data-test-terms]');
        await click('[data-test-submit]');

        assert.deepEqual(
          data,
          {
            firstName: 'Tony',
            lastName: 'Ward',
            gender: 'male',
            country: 'USA',
            comments: 'lorem ipsum',
            acceptTerms: false,
            age: 21,
          },
          'original data is not mutated'
        );

        assert.true(
          submitHandler.calledWith({
            firstName: 'Nicole',
            lastName: 'Chung',
            gender: 'female',
            country: 'CA',
            comments: 'foo bar',
            acceptTerms: true,
            age: 20,
          }),
          'new data is passed to submit handler'
        );
      });

      test('class object', async function (assert) {
        class MyData {
          constructor(public firstName: string, public lastName: string, public gender: 'male' | 'female' | 'other', public country: string, public comments: string, public acceptTerms: boolean, public age: number) {}
        }

        const data = new MyData(
          'Tony',
          'Ward',
          'male',
          'USA',
          'lorem ipsum',
          false,
          21,
        );
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
              <field.RadioGroup as |group|>
                <group.Radio @value="male" as |radio|>
                  <radio.Input data-test-gender-male />
                  <radio.Label>Male</radio.Label>
                </group.Radio>
                <group.Radio @value="female" as |radio|>
                  <radio.Input data-test-gender-female />
                  <radio.Label>Female</radio.Label>
                </group.Radio>
                <group.Radio @value="other" as |radio|>
                  <radio.Input data-test-gender-other />
                  <radio.Label>Other</radio.Label>
                </group.Radio>
              </field.RadioGroup>
            </form.Field>
            <form.Field @name="age" as |field|>
              <field.Label>Age</field.Label>
              <field.Input @type="number" data-test-age />
            </form.Field>
            <form.Field @name="country" as |field|>
              <field.Label>Country</field.Label>
              <field.Select data-test-country as |select|>
                <select.Option @value="USA">United States</select.Option>
                <select.Option @value="CA">Canada</select.Option>
              </field.Select>
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
        await select('select[data-test-country]', 'CA');
        await click('input[data-test-gender-female]');
        await fillIn('input[data-test-age]', '20');
        await fillIn('textarea[data-test-comments]', 'foo bar');
        await click('input[data-test-terms]');
        await click('[data-test-submit]');

        assert.propContains(
          data,
          {
            firstName: 'Tony',
            lastName: 'Ward',
            gender: 'male',
            country: 'USA',
            comments: 'lorem ipsum',
            acceptTerms: false,
            age: 21,
          },
          'original data is not mutated'
        );

        assert.true(
          submitHandler.calledWith({
            firstName: 'Nicole',
            lastName: 'Chung',
            gender: 'female',
            country: 'CA',
            comments: 'foo bar',
            acceptTerms: true,
            age: 20,
          }),
          'new data is passed to submit handler'
        );
      });

       test('ember-data object', async function (assert) {
        const store = this.owner.lookup('service:store') as Store;

        const data = store.createRecord('user', {
          firstName: 'Tony',
          lastName: 'Ward',
          gender: 'male',
          country: 'USA',
          comments: 'lorem ipsum',
          acceptTerms: false,
          age: 21,
        });
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
              <field.RadioGroup as |group|>
                <group.Radio @value="male" as |radio|>
                  <radio.Input data-test-gender-male />
                  <radio.Label>Male</radio.Label>
                </group.Radio>
                <group.Radio @value="female" as |radio|>
                  <radio.Input data-test-gender-female />
                  <radio.Label>Female</radio.Label>
                </group.Radio>
                <group.Radio @value="other" as |radio|>
                  <radio.Input data-test-gender-other />
                  <radio.Label>Other</radio.Label>
                </group.Radio>
              </field.RadioGroup>
            </form.Field>
            <form.Field @name="age" as |field|>
              <field.Label>Age</field.Label>
              <field.Input @type="number" data-test-age />
            </form.Field>
            <form.Field @name="country" as |field|>
              <field.Label>Country</field.Label>
              <field.Select data-test-country as |select|>
                <select.Option @value="USA">United States</select.Option>
                <select.Option @value="CA">Canada</select.Option>
              </field.Select>
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
        await select('select[data-test-country]', 'CA');
        await click('input[data-test-gender-female]');
        await fillIn('input[data-test-age]', '20');
        await fillIn('textarea[data-test-comments]', 'foo bar');
        await click('input[data-test-terms]');
        await click('[data-test-submit]');

        assert.strictEqual(data.firstName, 'Tony');
        assert.strictEqual(data.lastName, 'Ward');
        assert.strictEqual(data.gender, 'male');
        assert.strictEqual(data.country, 'USA');
        assert.strictEqual(data.comments, 'lorem ipsum');
        assert.false(data.acceptTerms);
        assert.strictEqual(data.age, 21);

        assert.true(
          submitHandler.calledWithMatch({
            firstName: 'Nicole',
            lastName: 'Chung',
            gender: 'female',
            country: 'CA',
            comments: 'foo bar',
            acceptTerms: true,
            age: 20,
          }),
          'new data is passed to submit handler'
        );
      });
    });

    test('submit action is yielded', async function (assert) {
      const data = {
        firstName: 'Tony',
        lastName: 'Ward',
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
          <button
            type="button"
            data-test-submit
            {{on "click" form.submit}}
          >Submit</button>
        </HeadlessForm>
      </template>);

      assert.dom('input[data-test-first-name]').hasValue('Tony');
      assert.dom('input[data-test-last-name]').hasValue('Ward');

      await fillIn('input[data-test-first-name]', 'Nicole');
      await fillIn('input[data-test-last-name]', 'Chung');

      await click('[data-test-submit]');

      assert.true(
        submitHandler.calledWith({
          firstName: 'Nicole',
          lastName: 'Chung',
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
