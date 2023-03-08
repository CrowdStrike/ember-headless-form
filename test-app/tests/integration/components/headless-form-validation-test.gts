/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { tracked } from '@glimmer/tracking';
import { blur, click, fillIn, render, rerender } from '@ember/test-helpers';
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

module('Integration Component HeadlessForm > Validation', function (hooks) {
  setupRenderingTest(hooks);

  interface TestFormData {
    firstName?: string;
    lastName?: string;
  }

  const validateFormCallbackSync: FormValidateCallback<TestFormData> = (
    data,
    fields
  ) => {
    const errorRecord: ErrorRecord<TestFormData> = {};

    for (const field of fields) {
      const value = data[field];
      const errors: ValidationError<string | undefined>[] = [];
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

      if (errors.length > 0) {
        errorRecord[field as keyof TestFormData] = errors;
      }
    }

    return errorRecord;
  };

  const validateFormCallbackAsync: FormValidateCallback<TestFormData> = async (
    data,
    fields
  ) => {
    // intentionally adding a delay here, to make the validation behave truly async and assert that we are correctly waiting for it in tests
    await new Promise((resolve) => setTimeout(resolve, 10));
    return validateFormCallbackSync(data, fields);
  };

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

  module('form @validation callback', function () {
    [
      { testType: 'sync', validateCallback: validateFormCallbackSync },
      { testType: 'async', validateCallback: validateFormCallbackAsync },
    ].forEach(({ testType, validateCallback }) =>
      module(testType, function () {
        test('validation callback is called on submit', async function (assert) {
          const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
          const validateCallback = sinon.spy();

          await render(<template>
            <HeadlessForm
              @data={{data}}
              @validate={{validateCallback}}
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

          await click('[data-test-submit]');

          assert.true(
            validateCallback.calledWith(data),
            '@validate is called with form data'
          );
        });

        test('onSubmit is not called when validation fails', async function (assert) {
          const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };
          const submitHandler = sinon.spy();

          await render(<template>
            <HeadlessForm
              @data={{data}}
              @validate={{validateCallback}}
              @onSubmit={{submitHandler}}
              as |form|
            >
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
              </form.Field>
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
              @validate={{validateCallback}}
              @onInvalid={{invalidHandler}}
              as |form|
            >
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
              </form.Field>
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
              @validate={{validateCallback}}
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

        test('validation errors are exposed as field.Errors on submit', async function (assert) {
          const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };

          await render(<template>
            <HeadlessForm
              @data={{data}}
              @validate={{validateCallback}}
              as |form|
            >
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
                <field.Errors data-test-first-name-errors />
              </form.Field>
              <form.Field @name="lastName" as |field|>
                <field.Label>Last Name</field.Label>
                <field.Input data-test-last-name />
                <field.Errors data-test-last-name-errors />
              </form.Field>
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
            .exists(
              { count: 1 },
              'validation errors appear when validation fails'
            );
          assert
            .dom('[data-test-last-name-errors]')
            .doesNotExist(
              'validation errors are not rendered when validation succeeds'
            );
        });

        test('field.Errors is associated to input', async function (this: RenderingTestContext, assert) {
          const data: TestFormData = { firstName: 'Foo' };

          await render(<template>
            <HeadlessForm
              @data={{data}}
              @validate={{validateCallback}}
              as |form|
            >
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
                <field.Errors data-test-first-name-errors />
              </form.Field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          assert
            .dom('input')
            .doesNotHaveAria('invalid')
            .doesNotHaveAria('describedby');

          assert.dom('[data-test-first-name-errors]').doesNotExist();

          await click('[data-test-submit]');

          assert
            .dom('[data-test-first-name-errors]')
            .hasAttribute(
              'id',
              // copied from https://ihateregex.io/expr/uuid/
              /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/,
              'errors element has id with dynamically generated uuid'
            )
            .hasAria('live', 'assertive');

          const id =
            this.element.querySelector('[data-test-first-name-errors]')?.id ??
            '';

          assert
            .dom('input')
            .hasAria('invalid', 'true')
            .hasAria(
              'describedby',
              id,
              'errors are associated to invalid input via aria-describedby'
            );
        });

        test('field.Errors renders all error messages in non-block mode', async function (assert) {
          const data: TestFormData = { firstName: 'foo' };

          await render(<template>
            <HeadlessForm
              @data={{data}}
              @validate={{validateCallback}}
              as |form|
            >
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
                <field.Errors data-test-first-name-errors />
              </form.Field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          await click('[data-test-submit]');

          assert
            .dom('[data-test-first-name-errors]')
            .exists({ count: 1 })
            .hasText(
              'firstName must be upper case! Foo is an invalid firstName!'
            );
        });

        test('field.Errors yields errors in block mode', async function (assert) {
          const data: TestFormData = { firstName: 'foo' };

          await render(<template>
            <HeadlessForm
              @data={{data}}
              @validate={{validateCallback}}
              as |form|
            >
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
                <field.Errors data-test-first-name-errors as |errors|>
                  {{#each errors as |e|}}
                    <div data-test-error>
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
                </field.Errors>
              </form.Field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          await click('[data-test-submit]');

          assert.dom('[data-test-first-name-errors]').exists({ count: 1 });
          assert
            .dom('[data-test-first-name-errors] [data-test-error]')
            .exists({ count: 2 });

          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-type]'
            )
            .hasText('uppercase');
          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-value]'
            )
            .hasText('foo');
          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-message]'
            )
            .hasText('firstName must be upper case!');

          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error]:last-child [data-test-error-type]'
            )
            .hasText('notFoo');
          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error]:last-child [data-test-error-value]'
            )
            .hasText('foo');
          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error]:last-child [data-test-error-message]'
            )
            .hasText('Foo is an invalid firstName!');
        });

        test('validation errors for dynamically removed fields are not taken into account', async function (assert) {
          const data: TestFormData = {};
          const submitHandler = sinon.spy();
          // This validation callback intentionally always returns an error, as it should be ignored
          const validateCallback = () => ({
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
                <form.Field @name="firstName" as |field|>
                  <field.Label>First Name</field.Label>
                  <field.Input data-test-first-name />
                  <field.Errors data-test-first-name-errors />
                </form.Field>
              {{/if}}
              {{#if formState.showLastName}}
                <form.Field @name="lastName" as |field|>
                  <field.Label>Last Name</field.Label>
                  <field.Input data-test-last-name />
                  <field.Errors data-test-last-name-errors />
                </form.Field>
              {{/if}}
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          await click('[data-test-submit]');

          assert
            .dom('[data-test-first-name-errors]')
            .exists(
              'validation errors are shown for firstName while being visible'
            );
          assert
            .dom('[data-test-last-name-errors]')
            .exists(
              'validation errors are shown for lastName while being visible'
            );
          assert.false(submitHandler.called, '@onSubmit has not been called');

          formState.showFirstName = false;

          await rerender();
          await click('[data-test-submit]');

          assert.dom('[data-test-first-name-errors]').doesNotExist();
          assert
            .dom('[data-test-last-name-errors]')
            .exists(
              'validation errors are shown for lastName while being visible'
            );
          assert.false(submitHandler.called, '@onSubmit has not been called');

          formState.showLastName = false;

          await rerender();
          await click('[data-test-submit]');

          assert.dom('[data-test-first-name-errors]').doesNotExist();
          assert.dom('[data-test-last-name-errors]').doesNotExist();
          assert.true(
            submitHandler.called,
            '@onSubmit has been called when no invalid field is left'
          );

          formState.showFirstName = true;
          await rerender();

          assert
            .dom('[data-test-first-name-errors]')
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
          const data: TestFormData = { firstName: 'Foo' };

          await render(<template>
            <HeadlessForm
              @data={{data}}
              @validate={{validateCallback}}
              as |form|
            >
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
              </form.Field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          await click('[data-test-submit]');

          assert.dom('[data-test-first-name]').hasAria('invalid', 'true');
        });
      })
    );
  });

  module('form.Field @validation callback', function () {
    [
      { testType: 'sync', validateCallback: validateFieldCallbackSync },
      { testType: 'async', validateCallback: validateFieldCallbackAsync },
    ].forEach(({ testType, validateCallback }) =>
      module(testType, function () {
        test('validation callback is called on submit', async function (assert) {
          const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
          const validateCallback = sinon.spy();

          await render(<template>
            <HeadlessForm @data={{data}} as |form|>
              <form.Field
                @name="firstName"
                @validate={{validateCallback}}
                as |field|
              >
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

          await click('[data-test-submit]');

          assert.true(
            validateCallback.calledWith(data.firstName, 'firstName', data),
            '@validate is called with form data'
          );
        });

        test('onSubmit is not called when validation fails', async function (assert) {
          const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };
          const submitHandler = sinon.spy();

          await render(<template>
            <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
              <form.Field
                @name="firstName"
                @validate={{validateCallback}}
                as |field|
              >
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
              </form.Field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          await click('[data-test-submit]');

          assert.false(submitHandler.called, '@onSubmit is not called');
        });

        test('validation errors are exposed as field.Errors on submit', async function (assert) {
          const data: TestFormData = { firstName: 'Foo', lastName: 'Smith' };

          await render(<template>
            <HeadlessForm @data={{data}} as |form|>
              <form.Field
                @name="firstName"
                @validate={{validateCallback}}
                as |field|
              >
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
                <field.Errors data-test-first-name-errors />
              </form.Field>
              <form.Field @name="lastName" as |field|>
                <field.Label>Last Name</field.Label>
                <field.Input data-test-last-name />
                <field.Errors data-test-last-name-errors />
              </form.Field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          await click('[data-test-submit]');

          assert.dom('[data-test-first-name-errors]').exists({ count: 1 });
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
                <form.Field
                  @name="firstName"
                  @validate={{validateCallback}}
                  as |field|
                >
                  <field.Label>First Name</field.Label>
                  <field.Input data-test-first-name />
                  <field.Errors data-test-first-name-errors />
                </form.Field>
              {{/if}}
              {{#if formState.showLastName}}
                <form.Field
                  @name="lastName"
                  @validate={{validateCallback}}
                  as |field|
                >
                  <field.Label>Last Name</field.Label>
                  <field.Input data-test-last-name />
                  <field.Errors data-test-last-name-errors />
                </form.Field>
              {{/if}}
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          await click('[data-test-submit]');

          assert
            .dom('[data-test-first-name-errors]')
            .exists(
              'validation errors are shown for firstName while being visible'
            );
          assert
            .dom('[data-test-last-name-errors]')
            .exists(
              'validation errors are shown for lastName while being visible'
            );
          assert.false(submitHandler.called, '@onSubmit has not been called');

          formState.showFirstName = false;

          await rerender();
          await click('[data-test-submit]');

          assert.dom('[data-test-first-name-errors]').doesNotExist();
          assert
            .dom('[data-test-last-name-errors]')
            .exists(
              'validation errors are shown for lastName while being visible'
            );
          assert.false(submitHandler.called, '@onSubmit has not been called');

          formState.showLastName = false;

          await rerender();
          await click('[data-test-submit]');

          assert.dom('[data-test-first-name-errors]').doesNotExist();
          assert.dom('[data-test-last-name-errors]').doesNotExist();
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
              <form.Field
                @name="firstName"
                @validate={{fieldValidateCallback}}
                as |field|
              >
                <field.Label>First Name</field.Label>
                <field.Input data-test-first-name />
                <field.Errors data-test-first-name-errors as |errors|>
                  {{#each errors as |e index|}}
                    <div data-test-error={{index}}>
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
                </field.Errors>
              </form.Field>
              <form.Field @name="lastName" as |field|>
                <field.Label>Last Name</field.Label>
                <field.Input data-test-last-name />
                <field.Errors data-test-last-name-errors />
              </form.Field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          await click('[data-test-submit]');

          assert
            .dom('[data-test-first-name-errors] [data-test-error]')
            .exists({ count: 2 });

          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-type]'
            )
            .hasText('uppercase');
          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-value]'
            )
            .hasText('foo');
          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-message]'
            )
            .hasText('First name must be upper case!');

          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error="1"] [data-test-error-type]'
            )
            .hasText('notFoo');
          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error="1"] [data-test-error-value]'
            )
            .hasText('foo');
          assert
            .dom(
              '[data-test-first-name-errors] [data-test-error="1"] [data-test-error-message]'
            )
            .hasText('Foo is an invalid first name!');

          assert.dom('[data-test-last-name-errors]').doesNotExist();
        });
      })
    );
  });

  module(`@validateOn`, function () {
    module('@validateOn=focusout', function () {
      test('form validation callback is called on focusout', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validateOn="focusout"
            @validate={{validateCallback}}
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.false(
          validateCallback.called,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.true(
          validateCallback.calledWith({ ...data, firstName: 'Foo' }),
          '@validate is called with form data on focusout'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called again on submit'
        );
      });

      test('field validation callback is called on focusout', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} @validateOn="focusout" as |form|>
            <form.Field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.false(
          validateCallback.called,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.true(
          validateCallback.calledWith('Foo', 'firstName', {
            ...data,
            firstName: 'Foo',
          }),
          '@validate is called with form data on focusout'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called again on submit'
        );
      });

      test('validation errors are exposed as field.Errors on focusout', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Foo' };

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validateOn="focusout"
            @validate={{validateFormCallbackSync}}
            as |form|
          >
            <form.Field @name="firstName" as |field|>
              <field.Label>First Name</field.Label>
              <field.Input data-test-first-name />
              <field.Errors data-test-first-name-errors />
            </form.Field>
            <form.Field @name="lastName" as |field|>
              <field.Label>Last Name</field.Label>
              <field.Input data-test-last-name />
              <field.Errors data-test-last-name-errors />
            </form.Field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before form is filled in'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before form is filled in'
          );

        await fillIn('[data-test-first-name]', 'Foo');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before validation happens on focusout'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before validation happens on focusout'
          );

        await blur('[data-test-first-name]');

        assert
          .dom('[data-test-first-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on focusout when validation fails'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered for untouched fields'
          );
      });
    });

    module('@validateOn=change', function () {
      test('form validation callback is called on change', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validateOn="change"
            @validate={{validateCallback}}
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.true(
          validateCallback.calledWith({ ...data, firstName: 'Foo' }),
          '@validate is called with form data on change'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called again on submit'
        );
      });

      test('field validation callback is called on change', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} @validateOn="change" as |form|>
            <form.Field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.true(
          validateCallback.calledWith('Foo', 'firstName', {
            ...data,
            firstName: 'Foo',
          }),
          '@validate is called with form data'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called again on submit'
        );
      });

      test('validation errors are exposed as field.Errors on change', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Foo' };

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validateOn="change"
            @validate={{validateFormCallbackSync}}
            as |form|
          >
            <form.Field @name="firstName" as |field|>
              <field.Label>First Name</field.Label>
              <field.Input data-test-first-name />
              <field.Errors data-test-first-name-errors />
            </form.Field>
            <form.Field @name="lastName" as |field|>
              <field.Label>Last Name</field.Label>
              <field.Input data-test-last-name />
              <field.Errors data-test-last-name-errors />
            </form.Field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before validation happens on change'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before validation happens on change'
          );

        await fillIn('[data-test-first-name]', 'Foo');

        assert
          .dom('[data-test-first-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on focusout when validation fails'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered for untouched fields'
          );
      });
    });

    module('@validateOn=input', function () {
      test('form validation callback is called on input', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validateOn="input"
            @validate={{validateCallback}}
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

        await input('[data-test-first-name]', 'Foo');

        assert.true(
          validateCallback.calledWith({ ...data, firstName: 'Foo' }),
          '@validate is called with form data on input'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called again on submit'
        );
      });

      test('field validation callback is called on input', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} @validateOn="input" as |form|>
            <form.Field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
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

        await input('[data-test-first-name]', 'Foo');

        assert.true(
          validateCallback.calledWith('Foo', 'firstName', {
            ...data,
            firstName: 'Foo',
          }),
          '@validate is called with form data'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called again on submit'
        );
      });

      test('validation errors are exposed as field.Errors on input', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Foo' };

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validateOn="input"
            @validate={{validateFormCallbackSync}}
            as |form|
          >
            <form.Field @name="firstName" as |field|>
              <field.Label>First Name</field.Label>
              <field.Input data-test-first-name />
              <field.Errors data-test-first-name-errors />
            </form.Field>
            <form.Field @name="lastName" as |field|>
              <field.Label>Last Name</field.Label>
              <field.Input data-test-last-name />
              <field.Errors data-test-last-name-errors />
            </form.Field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before validation happens on input'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before validation happens on input'
          );

        await input('[data-test-first-name]', 'Foo');

        assert
          .dom('[data-test-first-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on input when validation fails'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered for untouched fields'
          );
      });
    });
  });

  module(`@revalidateOn`, function () {
    module('@revalidateOn=focusout', function () {
      test('form validation callback is called on focusout', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @revalidateOn="focusout"
            @validate={{validateCallback}}
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.false(
          validateCallback.called,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.false(
          validateCallback.called,
          '@validate is not called until submitting'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledOnce,
          '@validate is called when submitting'
        );
        assert.true(
          validateCallback.calledWith({ ...data, firstName: 'Foo' }),
          '@validate is called with form data on submit'
        );

        await fillIn('[data-test-first-name]', 'Tony');

        assert.false(
          validateCallback.calledTwice,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called for revalidation on focusout'
        );
        assert.true(
          validateCallback
            .getCall(1)
            .calledWith({ ...data, firstName: 'Tony' }),
          '@validate is called with form data on focusout'
        );
      });

      test('field validation callback is called on focusout', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} @revalidateOn="focusout" as |form|>
            <form.Field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.false(
          validateCallback.called,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.false(
          validateCallback.called,
          '@validate is not called until submitting'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledOnce,
          '@validate is called when submitting'
        );
        assert.true(
          validateCallback.calledWith('Foo', 'firstName', {
            ...data,
            firstName: 'Foo',
          }),
          '@validate is called with form data'
        );

        await fillIn('[data-test-first-name]', 'Tony');

        assert.false(
          validateCallback.calledTwice,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called for revalidation on focusout'
        );
        assert.true(
          validateCallback.getCall(1).calledWith('Tony', 'firstName', {
            ...data,
            firstName: 'Tony',
          }),
          '@validate is called with form data'
        );
      });

      test('validation errors are exposed as field.Errors on focusout', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Foo' };

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @revalidateOn="focusout"
            @validate={{validateFormCallbackSync}}
            as |form|
          >
            <form.Field @name="firstName" as |field|>
              <field.Label>First Name</field.Label>
              <field.Input data-test-first-name />
              <field.Errors data-test-first-name-errors />
            </form.Field>
            <form.Field @name="lastName" as |field|>
              <field.Label>Last Name</field.Label>
              <field.Input data-test-last-name />
              <field.Errors data-test-last-name-errors />
            </form.Field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens before form is filled in'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens before form is filled in'
          );

        await fillIn('[data-test-first-name]', 'Foo');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );

        await blur('[data-test-first-name]');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );

        await click('[data-test-submit]');

        assert
          .dom('[data-test-first-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on submit when validation fails'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on submit when validation fails'
          );

        await fillIn('[data-test-first-name]', 'Tony');

        assert
          .dom('[data-test-first-name-errors]')
          .exists(
            { count: 1 },
            'validation errors do not disappear until revalidation happens on focusout'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .exists(
            { count: 1 },
            'validation errors do not disappear until revalidation happens on focusout'
          );

        await blur('[data-test-first-name]');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors disappear after successful revalidation on focusout'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .exists(
            { count: 1 },
            'validation errors do not disappear until revalidation happens on focusout'
          );
      });
    });

    module('@revalidateOn=change', function () {
      test('form validation callback is called on change', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @revalidateOn="change"
            @validate={{validateCallback}}
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.false(
          validateCallback.called,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.false(
          validateCallback.called,
          '@validate is not called until submitting'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledOnce,
          '@validate is called when submitting'
        );
        assert.true(
          validateCallback.calledWith({ ...data, firstName: 'Foo' }),
          '@validate is called with form data'
        );

        await fillIn('[data-test-first-name]', 'Tony');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called for revalidation on change'
        );
        assert.true(
          validateCallback
            .getCall(1)
            .calledWith({ ...data, firstName: 'Tony' }),
          '@validate is called with form data'
        );

        await blur('[data-test-first-name]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is not called again on focusout'
        );
      });

      test('field validation callback is called on change', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} @revalidateOn="change" as |form|>
            <form.Field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.false(
          validateCallback.called,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.false(
          validateCallback.called,
          '@validate is not called until submitting'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledOnce,
          '@validate is called when submitting'
        );
        assert.true(
          validateCallback.calledWith('Foo', 'firstName', {
            ...data,
            firstName: 'Foo',
          }),
          '@validate is called with form data'
        );

        await fillIn('[data-test-first-name]', 'Tony');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called for revalidation on change'
        );
        assert.true(
          validateCallback.getCall(1).calledWith('Tony', 'firstName', {
            ...data,
            firstName: 'Tony',
          }),
          '@validate is called with form data'
        );

        await blur('[data-test-first-name]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called for revalidation on focusout'
        );
      });

      test('validation errors are exposed as field.Errors on change', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Foo' };

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @revalidateOn="change"
            @validate={{validateFormCallbackSync}}
            as |form|
          >
            <form.Field @name="firstName" as |field|>
              <field.Label>First Name</field.Label>
              <field.Input data-test-first-name />
              <field.Errors data-test-first-name-errors />
            </form.Field>
            <form.Field @name="lastName" as |field|>
              <field.Label>Last Name</field.Label>
              <field.Input data-test-last-name />
              <field.Errors data-test-last-name-errors />
            </form.Field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens before form is filled in'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens before form is filled in'
          );

        await fillIn('[data-test-first-name]', 'Foo');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );

        await blur('[data-test-first-name]');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );

        await click('[data-test-submit]');

        assert
          .dom('[data-test-first-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on submit when validation fails'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on submit when validation fails'
          );

        await fillIn('[data-test-first-name]', 'Tony');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors disappear after successful revalidation on change'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .exists(
            { count: 1 },
            'validation errors do not disappear until revalidation happens on change'
          );
      });
    });

    module('@revalidateOn=input', function () {
      test('form validation callback is called on input', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @revalidateOn="input"
            @validate={{validateCallback}}
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.false(
          validateCallback.called,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.false(
          validateCallback.called,
          '@validate is not called until submitting'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledOnce,
          '@validate is called when submitting'
        );
        assert.true(
          validateCallback.calledWith({ ...data, firstName: 'Foo' }),
          '@validate is called with form data'
        );

        await input('[data-test-first-name]', 'Tony');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called for revalidation on input'
        );
        assert.true(
          validateCallback
            .getCall(1)
            .calledWith({ ...data, firstName: 'Tony' }),
          '@validate is called with form data'
        );

        await blur('[data-test-first-name]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is not called again on focusout'
        );
      });

      test('field validation callback is called on input', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Ward' };
        const validateCallback = sinon.spy();

        await render(<template>
          <HeadlessForm @data={{data}} @revalidateOn="input" as |form|>
            <form.Field
              @name="firstName"
              @validate={{validateCallback}}
              as |field|
            >
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

        await fillIn('[data-test-first-name]', 'Foo');

        assert.false(
          validateCallback.called,
          '@validate is not called while typing'
        );

        await blur('[data-test-first-name]');

        assert.false(
          validateCallback.called,
          '@validate is not called until submitting'
        );

        await click('[data-test-submit]');

        assert.true(
          validateCallback.calledOnce,
          '@validate is called when submitting'
        );
        assert.true(
          validateCallback.calledWith('Foo', 'firstName', {
            ...data,
            firstName: 'Foo',
          }),
          '@validate is called with form data'
        );

        await input('[data-test-first-name]', 'Tony');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called for revalidation on input'
        );
        assert.true(
          validateCallback.getCall(1).calledWith('Tony', 'firstName', {
            ...data,
            firstName: 'Tony',
          }),
          '@validate is called with form data'
        );

        await blur('[data-test-first-name]');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called for revalidation on focusout'
        );
      });

      test('validation errors are exposed as field.Errors on input', async function (assert) {
        const data: TestFormData = { firstName: 'Tony', lastName: 'Foo' };

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @revalidateOn="input"
            @validate={{validateFormCallbackSync}}
            as |form|
          >
            <form.Field @name="firstName" as |field|>
              <field.Label>First Name</field.Label>
              <field.Input data-test-first-name />
              <field.Errors data-test-first-name-errors />
            </form.Field>
            <form.Field @name="lastName" as |field|>
              <field.Label>Last Name</field.Label>
              <field.Input data-test-last-name />
              <field.Errors data-test-last-name-errors />
            </form.Field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens before form is filled in'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens before form is filled in'
          );

        await fillIn('[data-test-first-name]', 'Foo');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );

        await blur('[data-test-first-name]');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .doesNotExist(
            'validation errors are not rendered before initial validation happens on submit'
          );

        await click('[data-test-submit]');

        assert
          .dom('[data-test-first-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on submit when validation fails'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .exists(
            { count: 1 },
            'validation errors appear on submit when validation fails'
          );

        await input('[data-test-first-name]', 'Tony');

        assert
          .dom('[data-test-first-name-errors]')
          .doesNotExist(
            'validation errors disappear after successful revalidation on input'
          );
        assert
          .dom('[data-test-last-name-errors]')
          .exists(
            { count: 1 },
            'validation errors do not disappear until revalidation happens on input'
          );
      });
    });
  });

  module('validation state', function () {
    test('form yields isInvalid', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm
          @data={{data}}
          @validate={{validateFormCallbackSync}}
          as |form|
        >
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
          {{#if form.isInvalid}}
            <div data-test-invalid />
          {{/if}}
        </HeadlessForm>
      </template>);

      assert.dom('[data-test-invalid]').doesNotExist();

      await click('[data-test-submit]');

      assert.dom('[data-test-invalid]').exists();

      await fillIn('[data-test-first-name]', 'Tony');
      await click('[data-test-submit]');

      assert.dom('[data-test-invalid]').doesNotExist();
    });

    test('field yields isInvalid', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm
          @data={{data}}
          @validate={{validateFormCallbackSync}}
          as |form|
        >
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
            {{#if field.isInvalid}}
              <div data-test-invalid />
            {{/if}}
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      assert.dom('[data-test-invalid]').doesNotExist();

      await click('[data-test-submit]');

      assert.dom('[data-test-invalid]').exists();

      await fillIn('[data-test-first-name]', 'Tony');
      await click('[data-test-submit]');

      assert.dom('[data-test-invalid]').doesNotExist();
    });

    test('field yields rawErrors', async function (assert) {
      const data: TestFormData = { firstName: 'foo' };

      await render(<template>
        <HeadlessForm
          @data={{data}}
          @validate={{validateFormCallbackSync}}
          as |form|
        >
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input data-test-first-name />
            <div data-test-first-name-errors>
              {{#each field.rawErrors as |e|}}
                <div data-test-error>
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
            </div>
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      await click('[data-test-submit]');

      assert
        .dom('[data-test-first-name-errors] [data-test-error]')
        .exists({ count: 2 });

      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-type]'
        )
        .hasText('uppercase');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-value]'
        )
        .hasText('foo');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-message]'
        )
        .hasText('firstName must be upper case!');

      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:last-child [data-test-error-type]'
        )
        .hasText('notFoo');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:last-child [data-test-error-value]'
        )
        .hasText('foo');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:last-child [data-test-error-message]'
        )
        .hasText('Foo is an invalid firstName!');
    });
  });
});
