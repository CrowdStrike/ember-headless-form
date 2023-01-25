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
  setupOnerror,
} from '@ember/test-helpers';
import { module, skip, test } from 'qunit';

import HeadlessForm from 'ember-headless-form/components/headless-form';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { RenderingTestContext } from '@ember/test-helpers';
import type { InputType } from 'ember-headless-form';

module('Integration Component headless-form', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders form markup', async function (assert) {
    await render(<template><HeadlessForm class="foo" novalidate /></template>);

    assert.dom('form').exists('it renders as <form>');
    assert
      .dom('form')
      .hasClass('foo', 'it accepts custom HTML classes')
      .hasAttribute('novalidate', '', 'it accepts arbitrary HTML attributes');
  });

  module('form.field', function () {
    test('form yields field component', async function (assert) {
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName">
            <div data-test-user-content>foo</div>
          </form.field>
        </HeadlessForm>
      </template>);

      assert
        .dom('[data-test-user-content]')
        .exists('form field can render user content');

      assert
        .dom('form > [data-test-user-content]')
        .exists('field component contains no markup itself');
    });

    test('@name must be unique', async function (assert) {
      assert.expect(1);
      const data = { firstName: 'Simon' };

      setupOnerror((e: Error) => {
        assert.strictEqual(
          e.message,
          'Assertion Failed: You passed @name="firstName" to the form field, but this is already in use. Names of form fields must be unique!',
          'Expected assertion error message'
        );
      });

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" />
          <form.field @name="firstName" />
        </HeadlessForm>
      </template>);
    });

    test('id is yielded from field component', async function (this: RenderingTestContext, assert) {
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <div data-test-id>{{field.id}}</div>
            <field.input />
          </form.field>
        </HeadlessForm>
      </template>);

      const inputId = this.element.querySelector('input')?.id;
      const id = (this.element.querySelector('[data-test-id]') as HTMLElement)
        .innerText;

      assert.strictEqual(id, inputId, "yielded ID matches input's id");
    });
  });

  module('field.label', function () {
    test('field yields label component', async function (assert) {
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label class="my-label" data-test-label>First Name</field.label>
          </form.field>
        </HeadlessForm>
      </template>);

      assert
        .dom('label')
        .hasText('First Name', 'it renders block content')
        .hasClass('my-label', 'it accepts custom HTML classes')
        .hasAttribute(
          'data-test-label',
          '',
          'it accepts arbitrary HTML attributes'
        );
    });

    test('label and input are connected', async function (this: RenderingTestContext, assert) {
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.label>First Name</field.label>
            <field.input />
          </form.field>
        </HeadlessForm>
      </template>);

      assert.dom('input').hasAttribute(
        'id',
        // copied from https://ihateregex.io/expr/uuid/
        /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/,
        'input has id with dynamically generated uuid'
      );

      const id = this.element.querySelector('input')?.id ?? '';

      assert
        .dom('label')
        .hasAttribute(
          'for',
          id,
          'label is attached to input by `for` attribute'
        );
    });
  });

  module('field.input', function () {
    test('field yields input component', async function (assert) {
      const data: { firstName?: string } = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="firstName" as |field|>
            <field.input class="my-input" data-test-input />
          </form.field>
        </HeadlessForm>
      </template>);

      assert
        .dom('input')
        .exists('render an input')
        .hasClass('my-input', 'it accepts custom HTML classes')
        .hasAttribute(
          'data-test-input',
          '',
          'it accepts arbitrary HTML attributes'
        );
    });

    test('input accepts all supported types', async function (assert) {
      const data = { firstName: 'Simon' };
      const inputTypes: InputType[] = [
        'color',
        'date',
        'datetime-local',
        'email',
        'hidden',
        'month',
        'number',
        'password',
        'range',
        'search',
        'tel',
        'text',
        'time',
        'url',
        'week',
      ];

      for (const type of inputTypes) {
        await render(<template>
          <HeadlessForm @data={{data}} as |form|>
            <form.field @name="firstName" as |field|>
              <field.input @type={{type}} />
            </form.field>
          </HeadlessForm>
        </template>);

        assert.dom('input').hasAttribute('type', type, `supports type=${type}`);
      }
    });

    ['checkbox', 'radio'].forEach((type) =>
      test(`input throws for ${type} type handled by dedicated component`, async function (assert) {
        assert.expect(1);
        setupOnerror((e: Error) => {
          assert.strictEqual(
            e.message,
            `Assertion Failed: input component does not support @type="${type}" as there is a dedicated component for this. Please use the \`field.${type}\` instead!`,
            'Expected assertion error message'
          );
        });

        const data = { checked: false };

        await render(<template>
          <HeadlessForm @data={{data}} as |form|>
            <form.field @name="checked" as |field|>
              {{! @glint-expect-error }}
              <field.input @type={{type}} />
            </form.field>
          </HeadlessForm>
        </template>);
      })
    );
  });

  module('field.checkbox', function () {
    test('field yields checkbox component', async function (assert) {
      const data: { checked?: boolean } = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="checked" as |field|>
            <field.checkbox class="my-input" data-test-checkbox />
          </form.field>
        </HeadlessForm>
      </template>);

      assert
        .dom('input')
        .exists('render an input')
        .hasAttribute('type', 'checkbox')
        .hasClass('my-input', 'it accepts custom HTML classes')
        .hasAttribute(
          'data-test-checkbox',
          '',
          'it accepts arbitrary HTML attributes'
        );
    });

    test('checked property is mapped correctly to @data', async function (assert) {
      const data = { checked: true };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="checked" as |field|>
            <field.checkbox />
          </form.field>
        </HeadlessForm>
      </template>);

      assert.dom('input[type="checkbox"]').isChecked();
    });
  });

  module('field.radio', function () {
    test('field yields radio component', async function (assert) {
      const data: { choice?: string } = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="choice" as |field|>
            <field.radio @value="foo">
              Some content
            </field.radio>
          </form.field>
        </HeadlessForm>
      </template>);

      assert.dom('form').hasText('Some content', 'radio renders block content');

      assert
        .dom('form > *')
        .doesNotExist('radio component contains no markup itself');
    });

    test('radio yields label component', async function (assert) {
      const data: { choice?: string } = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="choice" as |field|>
            <field.radio @value="foo" as |radio|>
              <radio.label class="my-label" data-test-label>Foo</radio.label>
            </field.radio>
          </form.field>
        </HeadlessForm>
      </template>);

      assert
        .dom('label')
        .hasText('Foo', 'it renders block content')
        .hasClass('my-label', 'it accepts custom HTML classes')
        .hasAttribute(
          'data-test-label',
          '',
          'it accepts arbitrary HTML attributes'
        );
    });

    test('radio yields input component', async function (assert) {
      const data: { choice?: string } = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="choice" as |field|>
            <field.radio @value="foo" as |radio|>
              <radio.input class="my-input" data-test-radio />
            </field.radio>
          </form.field>
        </HeadlessForm>
      </template>);

      assert
        .dom('input')
        .exists('render an input')
        .hasAttribute('type', 'radio')
        .hasValue('foo')
        .hasClass('my-input', 'it accepts custom HTML classes')
        .hasAttribute(
          'data-test-radio',
          '',
          'it accepts arbitrary HTML attributes'
        );
    });

    test('label and input are connected', async function (this: RenderingTestContext, assert) {
      const data: { choice?: string } = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="choice" as |field|>
            <field.radio @value="foo" as |radio|>
              <radio.input />
              <radio.label>Foo</radio.label>
            </field.radio>
          </form.field>
        </HeadlessForm>
      </template>);

      assert.dom('input').hasAttribute(
        'id',
        // copied from https://ihateregex.io/expr/uuid/
        /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/,
        'input has id with dynamically generated uuid'
      );

      const id = this.element.querySelector('input')?.id ?? '';

      assert
        .dom('label')
        .hasAttribute(
          'for',
          id,
          'label is attached to input by `for` attribute'
        );
    });

    test('checked property is mapped correctly to @data', async function (assert) {
      const data: { choice?: string } = { choice: 'bar' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="choice" as |field|>
            <field.radio @value="foo" as |radio|>
              <radio.input data-test-radio1 />
              <radio.label>Foo</radio.label>
            </field.radio>
            <field.radio @value="bar" as |radio|>
              <radio.input data-test-radio2 />
              <radio.label>Bar</radio.label>
            </field.radio>
          </form.field>
        </HeadlessForm>
      </template>);

      assert.dom('input[data-test-radio1]').isNotChecked();
      assert.dom('input[data-test-radio2]').isChecked();
    });
  });

  module('field.textarea', function () {
    test('field yields textarea component', async function (assert) {
      const data: { checked?: boolean } = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="checked" as |field|>
            <field.textarea class="my-textarea" data-test-textarea />
          </form.field>
        </HeadlessForm>
      </template>);

      assert
        .dom('textarea')
        .exists('render a textarea')
        .hasClass('my-textarea', 'it accepts custom HTML classes')
        .hasAttribute(
          'data-test-textarea',
          '',
          'it accepts arbitrary HTML attributes'
        );
    });
  });

  module('data', function () {
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
            <form.field @name="firstName" as |field|>
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
            </form.field>
            <form.field @name="lastName" as |field|>
              <field.label>Last Name</field.label>
              <field.input data-test-last-name />
            </form.field>
            <form.field @name="gender" as |field|>
              <field.radio @value="male" as |radio|>
                <radio.input data-test-gender-male />
                <radio.label>Male</radio.label>
              </field.radio>
              <field.radio @value="female" as |radio|>
                <radio.input data-test-gender-female />
                <radio.label>Female</radio.label>
              </field.radio>
              <field.radio @value="other" as |radio|>
                <radio.input data-test-gender-other />
                <radio.label>Other</radio.label>
              </field.radio>
            </form.field>
            <form.field @name="comments" as |field|>
              <field.label>Comments</field.label>
              <field.textarea data-test-comments />
            </form.field>
            <form.field @name="acceptTerms" as |field|>
              <field.label>Terms accepted</field.label>
              <field.checkbox data-test-terms />
            </form.field>
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
            <form.field @name="firstName" as |field|>
              <div data-test-first-name>{{field.value}}</div>
            </form.field>
            <form.field @name="lastName" as |field|>
              <div data-test-last-name>{{field.value}}</div>
            </form.field>
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
            <form.field @name="firstName" as |field|>
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
            </form.field>
            <form.field @name="lastName" as |field|>
              <field.label>Last Name</field.label>
              <field.input data-test-last-name />
            </form.field>
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
            <form.field @name="firstName" as |field|>
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
            </form.field>
            <form.field @name="lastName" as |field|>
              <field.label>Last Name</field.label>
              <field.input data-test-last-name />
            </form.field>
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
            <form.field @name="firstName" as |field|>
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
            </form.field>
            <form.field @name="lastName" as |field|>
              <field.label>Last Name</field.label>
              <field.input data-test-last-name />
            </form.field>
            <form.field @name="gender" as |field|>
              <field.radio @value="male" as |radio|>
                <radio.input data-test-gender-male />
                <radio.label>Male</radio.label>
              </field.radio>
              <field.radio @value="female" as |radio|>
                <radio.input data-test-gender-female />
                <radio.label>Female</radio.label>
              </field.radio>
              <field.radio @value="other" as |radio|>
                <radio.input data-test-gender-other />
                <radio.label>Other</radio.label>
              </field.radio>
            </form.field>
            <form.field @name="comments" as |field|>
              <field.label>Comments</field.label>
              <field.textarea data-test-comments />
            </form.field>
            <form.field @name="acceptTerms" as |field|>
              <field.label>Terms accepted</field.label>
              <field.checkbox data-test-terms />
            </form.field>
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
            <form.field @name="firstName" as |field|>
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
            </form.field>
          </HeadlessForm>
        </template>);

        assert.dom('input[data-test-first-name]').hasValue('Tony');

        await click('[data-test-custom-control]');

        assert.deepEqual(data, { firstName: 'Tony' }, 'data is not mutated');

        assert.dom('input[data-test-first-name]').hasValue('Nicole');
      });
    });
  });

  module('validation', function () {
    module('form @validation callback', function () {
      test('validation callback is called on submit', async function (assert) {
        const data = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} @validate={{validateCallback}} as |form|>
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

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledWith(data),
          '@validate is called with form data'
        );
      });

      test('onSubmit is not called when validation fails', async function (assert) {
        const data = { firstName: 'Foo', lastName: 'Smith' };
        const submitHandler = sinon.spy();
        const validateCallback = ({ firstName }: { firstName: string }) =>
          firstName.toLowerCase() === 'foo'
            ? {
                firstName: [
                  {
                    type: 'notFoo',
                    value: firstName,
                    message: 'Foo is an invalid first name!',
                  },
                ],
              }
            : undefined;

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validate={{validateCallback}}
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
        const data = { firstName: 'Foo', lastName: 'Smith' };
        const invalidHandler = sinon.spy();
        const validateCallback = ({ firstName }: { firstName: string }) =>
          firstName.toLowerCase() === 'foo'
            ? {
                firstName: [
                  {
                    type: 'notFoo',
                    value: firstName,
                    message: 'Foo is an invalid first name!',
                  },
                ],
              }
            : undefined;

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validate={{validateCallback}}
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
                type: 'notFoo',
                value: 'Foo',
                message: 'Foo is an invalid first name!',
              },
            ],
          }),
          '@onInvalid was called'
        );
      });

      test('onSubmit is called with user data', async function (assert) {
        const data = {
          firstName: 'Tony',
          lastName: 'Ward',
          acceptTerms: false,
        };
        const submitHandler = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
            <form.field @name="firstName" as |field|>
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
            </form.field>
            <form.field @name="lastName" as |field|>
              <field.label>Last Name</field.label>
              <field.input data-test-last-name />
            </form.field>
            <form.field @name="acceptTerms" as |field|>
              <field.label>Terms accepted</field.label>
              <field.checkbox data-test-terms />
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert.dom('input[data-test-first-name]').hasValue('Tony');
        assert.dom('input[data-test-last-name]').hasValue('Ward');
        assert.dom('input[data-test-terms]').isNotChecked();

        await fillIn('input[data-test-first-name]', 'Nicole');
        await fillIn('input[data-test-last-name]', 'Chung');
        await click('input[data-test-terms]');
        await click('[data-test-submit]');

        assert.deepEqual(
          data,
          { firstName: 'Tony', lastName: 'Ward', acceptTerms: false },
          'data is not mutated'
        );

        assert.true(
          submitHandler.calledWith({
            firstName: 'Nicole',
            lastName: 'Chung',
            acceptTerms: true,
          }),
          'new data is passed to submit handler'
        );
      });

      test('validation errors are exposed as field.errors on submit', async function (assert) {
        const data = { firstName: 'Foo', lastName: 'Smith' };
        const validateCallback = ({ firstName }: { firstName: string }) =>
          firstName.toLowerCase() === 'foo'
            ? {
                firstName: [
                  {
                    type: 'notFoo',
                    value: firstName,
                    message: 'Foo is an invalid first name!',
                  },
                ],
              }
            : undefined;

        await render(<template>
          <HeadlessForm @data={{data}} @validate={{validateCallback}} as |form|>
            <form.field @name="firstName" as |field|>
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
              {{#each field.errors as |e|}}
                <div data-test-first-name-error>
                  <div data-test-error-type>
                    {{e.type}}
                  </div>
                  <div data-test-error-value>
                    {{e.value}}
                  </div>
                  <div data-test-error-message>
                    {{e.message}}
                  </div>
                </div>
              {{/each}}
            </form.field>
            <form.field @name="lastName" as |field|>
              <field.label>Last Name</field.label>
              <field.input data-test-last-name />
              {{#if field.errors}}
                <div data-test-last-name-errors />
              {{/if}}
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await click('[data-test-submit]');

        assert.dom('[data-test-first-name-error]').exists({ count: 1 });
        assert
          .dom('[data-test-first-name-error] [data-test-error-type]')
          .hasText('notFoo');
        assert
          .dom('[data-test-first-name-error] [data-test-error-value]')
          .hasText('Foo');
        assert
          .dom('[data-test-first-name-error] [data-test-error-message]')
          .hasText('Foo is an invalid first name!');

        assert.dom('[data-test-last-name-errors]').doesNotExist();
      });

      test('validation errors for dynamically removed fields are not taken into account', async function (assert) {
        const data: { firstName?: string; lastName?: string } = {};
        const submitHandler = sinon.spy();
        // This validation callback intentionally always returns an error, as it should be ignored
        const validateCallback = (formData: typeof data) => ({
          firstName: [
            {
              type: 'dummy',
              value: undefined,
            },
          ],
          lastName: [
            {
              type: 'dummy',
              value: undefined,
            },
          ],
        });

        class FormState {
          @tracked showFirstName = true;
          @tracked showLastName = true;
        }
        const formState = new FormState();

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validate={{validateCallback}}
            @onSubmit={{submitHandler}}
            as |form|
          >
            {{#if formState.showFirstName}}
              <form.field @name="firstName" as |field|>
                <field.label>First Name</field.label>
                <field.input data-test-first-name />
                {{#if field.errors}}
                  <div data-test-first-name-error />
                {{/if}}
              </form.field>
            {{/if}}
            {{#if formState.showLastName}}
              <form.field @name="lastName" as |field|>
                <field.label>Last Name</field.label>
                <field.input data-test-last-name />
                {{#if field.errors}}
                  <div data-test-last-name-error />
                {{/if}}
              </form.field>
            {{/if}}
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await click('[data-test-submit]');

        assert
          .dom('[data-test-first-name-error]')
          .exists(
            'validation errors are shown for firstName while being visible'
          );
        assert
          .dom('[data-test-last-name-error]')
          .exists(
            'validation errors are shown for lastName while being visible'
          );
        assert.false(submitHandler.called, '@onSubmit has not been called');

        formState.showFirstName = false;

        await rerender();
        await click('[data-test-submit]');

        assert.dom('[data-test-first-name-error]').doesNotExist();
        assert
          .dom('[data-test-last-name-error]')
          .exists(
            'validation errors are shown for lastName while being visible'
          );
        assert.false(submitHandler.called, '@onSubmit has not been called');

        formState.showLastName = false;

        await rerender();
        await click('[data-test-submit]');

        assert.dom('[data-test-first-name-error]').doesNotExist();
        assert.dom('[data-test-last-name-error]').doesNotExist();
        assert.true(
          submitHandler.called,
          '@onSubmit has been called when no invalid field is left'
        );

        formState.showFirstName = true;
        await rerender();

        assert
          .dom('[data-test-first-name-error]')
          .exists(
            'validation errors are shown for firstName when being visible again'
          );

        await click('[data-test-submit]');

        assert.true(
          submitHandler.calledOnce,
          '@onSubmit has not been called again'
        );
      });

      test('validation errors mark the control as invalid', async function (assert) {
        const data = { firstName: 'Foo' };
        const validateCallback = ({ firstName }: { firstName: string }) =>
          firstName.toLowerCase() === 'foo'
            ? {
                firstName: [
                  {
                    type: 'notFoo',
                    value: firstName,
                    message: 'Foo is an invalid first name!',
                  },
                ],
              }
            : undefined;

        await render(<template>
          <HeadlessForm @data={{data}} @validate={{validateCallback}} as |form|>
            <form.field @name="firstName" as |field|>
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await click('[data-test-submit]');

        assert.dom('[data-test-first-name]').hasAria('invalid', 'true');
      });
    });

    module('form.field @validation callback', function () {
      test('validation callback is called on submit', async function (assert) {
        const data = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} as |form|>
            <form.field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
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

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledWith(data.firstName, 'firstName', data),
          '@validate is called with form data'
        );
      });

      test('onSubmit is not called when validation fails', async function (assert) {
        const data = { firstName: 'Foo', lastName: 'Smith' };
        const submitHandler = sinon.spy();
        const validateCallback = (firstName: string) =>
          firstName.toLowerCase() === 'foo'
            ? [
                {
                  type: 'notFoo',
                  value: firstName,
                  message: 'Foo is an invalid first name!',
                },
              ]
            : undefined;

        await render(<template>
          <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
            <form.field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await click('[data-test-submit]');

        assert.false(submitHandler.called, '@onSubmit is not called');
      });

      test('validation errors are exposed as field.errors on submit', async function (assert) {
        const data = { firstName: 'Foo', lastName: 'Smith' };
        const validateCallback = (firstName: string) =>
          firstName.toLowerCase() === 'foo'
            ? [
                {
                  type: 'notFoo',
                  value: firstName,
                  message: 'Foo is an invalid first name!',
                },
              ]
            : undefined;

        await render(<template>
          <HeadlessForm @data={{data}} as |form|>
            <form.field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
              {{#each field.errors as |e|}}
                <div data-test-first-name-error>
                  <div data-test-error-type>
                    {{e.type}}
                  </div>
                  <div data-test-error-value>
                    {{e.value}}
                  </div>
                  <div data-test-error-message>
                    {{e.message}}
                  </div>
                </div>
              {{/each}}
            </form.field>
            <form.field @name="lastName" as |field|>
              <field.label>Last Name</field.label>
              <field.input data-test-last-name />
              {{#if field.errors}}
                <div data-test-last-name-errors />
              {{/if}}
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await click('[data-test-submit]');

        assert.dom('[data-test-first-name-error]').exists({ count: 1 });
        assert
          .dom('[data-test-first-name-error] [data-test-error-type]')
          .hasText('notFoo');
        assert
          .dom('[data-test-first-name-error] [data-test-error-value]')
          .hasText('Foo');
        assert
          .dom('[data-test-first-name-error] [data-test-error-message]')
          .hasText('Foo is an invalid first name!');

        assert.dom('[data-test-last-name-errors]').doesNotExist();
      });

      test('validation errors for dynamically removed fields are not taken into account', async function (assert) {
        const data: { firstName?: string; lastName?: string } = {};
        const submitHandler = sinon.spy();
        // This validation callback intentionally always returns an error, as it should be ignored
        const validateCallback = () => [
          {
            type: 'dummy',
            value: undefined,
          },
        ];

        class FormState {
          @tracked showFirstName = true;
          @tracked showLastName = true;
        }
        const formState = new FormState();

        await render(<template>
          <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
            {{#if formState.showFirstName}}
              <form.field
                @name="firstName"
                @validate={{validateCallback}}
                as |field|
              >
                <field.label>First Name</field.label>
                <field.input data-test-first-name />
                {{#if field.errors}}
                  <div data-test-first-name-error />
                {{/if}}
              </form.field>
            {{/if}}
            {{#if formState.showLastName}}
              <form.field
                @name="lastName"
                @validate={{validateCallback}}
                as |field|
              >
                <field.label>Last Name</field.label>
                <field.input data-test-last-name />
                {{#if field.errors}}
                  <div data-test-last-name-error />
                {{/if}}
              </form.field>
            {{/if}}
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await click('[data-test-submit]');

        assert
          .dom('[data-test-first-name-error]')
          .exists(
            'validation errors are shown for firstName while being visible'
          );
        assert
          .dom('[data-test-last-name-error]')
          .exists(
            'validation errors are shown for lastName while being visible'
          );
        assert.false(submitHandler.called, '@onSubmit has not been called');

        formState.showFirstName = false;

        await rerender();
        await click('[data-test-submit]');

        assert.dom('[data-test-first-name-error]').doesNotExist();
        assert
          .dom('[data-test-last-name-error]')
          .exists(
            'validation errors are shown for lastName while being visible'
          );
        assert.false(submitHandler.called, '@onSubmit has not been called');

        formState.showLastName = false;

        await rerender();
        await click('[data-test-submit]');

        assert.dom('[data-test-first-name-error]').doesNotExist();
        assert.dom('[data-test-last-name-error]').doesNotExist();
        assert.true(
          submitHandler.called,
          '@onSubmit has been called when no invalid field is left'
        );
      });

      test('field validation errors are merged with form validation errors', async function (assert) {
        const data = { firstName: 'foo', lastName: 'Smith' };
        const formValidateCallback = ({ firstName }: { firstName: string }) =>
          firstName.charAt(0).toUpperCase() !== firstName.charAt(0)
            ? {
                firstName: [
                  {
                    type: 'uppercase',
                    value: firstName,
                    message: 'First name must be upper case!',
                  },
                ],
              }
            : undefined;
        const fieldValidateCallback = (firstName: string) =>
          firstName.toLowerCase() === 'foo'
            ? [
                {
                  type: 'notFoo',
                  value: firstName,
                  message: 'Foo is an invalid first name!',
                },
              ]
            : undefined;

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validate={{formValidateCallback}}
            as |form|
          >
            <form.field
              @name="firstName"
              @validate={{fieldValidateCallback}}
              as |field|
            >
              <field.label>First Name</field.label>
              <field.input data-test-first-name />
              {{#each field.errors as |e index|}}
                <div data-test-first-name-error={{index}}>
                  <div data-test-error-type>
                    {{e.type}}
                  </div>
                  <div data-test-error-value>
                    {{e.value}}
                  </div>
                  <div data-test-error-message>
                    {{e.message}}
                  </div>
                </div>
              {{/each}}
            </form.field>
            <form.field @name="lastName" as |field|>
              <field.label>Last Name</field.label>
              <field.input data-test-last-name />
              {{#if field.errors}}
                <div data-test-last-name-errors />
              {{/if}}
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await click('[data-test-submit]');

        assert.dom('[data-test-first-name-error]').exists({ count: 2 });

        assert
          .dom('[data-test-first-name-error="0"] [data-test-error-type]')
          .hasText('uppercase');
        assert
          .dom('[data-test-first-name-error="0"] [data-test-error-value]')
          .hasText('foo');
        assert
          .dom('[data-test-first-name-error="0"] [data-test-error-message]')
          .hasText('First name must be upper case!');

        assert
          .dom('[data-test-first-name-error="1"] [data-test-error-type]')
          .hasText('notFoo');
        assert
          .dom('[data-test-first-name-error="1"] [data-test-error-value]')
          .hasText('foo');
        assert
          .dom('[data-test-first-name-error="1"] [data-test-error-message]')
          .hasText('Foo is an invalid first name!');

        assert.dom('[data-test-last-name-errors]').doesNotExist();
      });
    });
  });

  module('Glint', function () {
    // These tests are not testing any new run-time behaviour that isn't tested elsewhere already.
    // Rather they are here to make sure they pass glint checks, testing for their types constraints to work as expected
    // Note: @glint-expect-error behaves just as @ts-expect-error in that in surpresses an error when we *expect* it to error,
    // but it *also* fails when no expected error is actually present!

    test('@name argument only expects keys of @data', async function (assert) {
      assert.expect(0);
      // Note that we have only firstName here in the type that is passed to @data, no lastName!
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          {{! this is valid }}
          <form.field @name="firstName" />
          {{! @glint-expect-error this is expected to be a glint error, as "lastName" does not exist on the type of @data! }}
          <form.field @name="lastName" />
        </HeadlessForm>
      </template>);
    });

    test('@name argument only expects keys of @data w/ partial data', async function (assert) {
      assert.expect(0);
      const data: { firstName?: string } = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          {{! this is valid }}
          <form.field @name="firstName" />
          {{! @glint-expect-error this is expected to be a glint error, as "lastName" does not exist on the type of @data! }}
          <form.field @name="lastName" />
        </HeadlessForm>
      </template>);
    });

    test('@name argument w/ an untyped @data errors', async function (assert) {
      assert.expect(0);
      const data = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          {{! @glint-expect-error this is expected to be a glint error, as "lastName" does not exist on the type of @data! }}
          <form.field @name="firstName" />
        </HeadlessForm>
      </template>);
    });
  });
});
