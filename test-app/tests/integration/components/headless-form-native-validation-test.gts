/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { blur, click, fillIn, render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { RenderingTestContext } from '@ember/test-helpers';

module(
  'Integration Component HeadlessForm > Native validation',
  function (hooks) {
    setupRenderingTest(hooks);

    interface TestFormData {
      firstName?: string;
      lastName?: string;
    }

    test('form has novalidate to render custom validation errors', async function (assert) {
      const data: TestFormData = {};
      const submitHandler = sinon.spy();

      await render(<template>
        <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      assert.dom('form').hasAttribute('novalidate');
    });

    test('onSubmit is not called when validation fails', async function (assert) {
      const data: TestFormData = {};
      const submitHandler = sinon.spy();

      await render(<template>
        <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      await click('[data-test-submit]');

      assert.false(
        submitHandler.called,
        '@onSubmit is not called when required field in empty'
      );
    });

    test('onInvalid is called when validation fails', async function (assert) {
      const data: TestFormData = {};
      const invalidHandler = sinon.spy();

      await render(<template>
        <HeadlessForm @data={{data}} @onInvalid={{invalidHandler}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      await click('[data-test-submit]');

      assert.true(
        invalidHandler.calledOnce,
        '@onInvalid was called when required field in empty'
      );
    });

    test('onSubmit is called when validation passes', async function (assert) {
      const data: TestFormData = {};
      const submitHandler = sinon.spy();

      await render(<template>
        <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
          </form.Field>
          <form.Field @name="lastName" as |field|>
            <field.Label>Last Name</field.Label>
            <field.Input required data-test-last-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      await fillIn('input[data-test-first-name]', 'Nicole');
      await fillIn('input[data-test-last-name]', 'Chung');
      await click('[data-test-submit]');

      assert.true(submitHandler.called, '@onSubmit has been called');
    });

    test('validation errors are revalidated on submit', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
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
        .exists({ count: 1 }, 'validation errors appear when validation fails');
      assert
        .dom('[data-test-last-name-errors]')
        .doesNotExist(
          'validation errors are not rendered when validation succeeds'
        );
    });

    test('field.Errors renders all error messages in non-block mode', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
            <field.Errors data-test-first-name-errors />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      await click('[data-test-submit]');

      assert
        .dom('[data-test-first-name-errors]')
        .exists({ count: 1 })
        .hasAnyText(); // validation error message is browser and locale dependant, so testing against actual message would be very brittle.
    });

    test('field.Errors yields errors in block mode', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
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
        .exists({ count: 1 });

      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-type]'
        )
        .hasText('native');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-value]'
        )
        .hasNoText();
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-message]'
        )
        .hasAnyText(); // validation error message is browser and locale dependant, so testing against actual message would be very brittle.
    });

    test('works with setCustomValidity', async function (this: RenderingTestContext, assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
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

      const input = this.element.querySelector(
        '[data-test-first-name]'
      ) as HTMLInputElement;

      input.setCustomValidity('This is a custom error message');

      await click('[data-test-submit]');

      assert.dom('[data-test-first-name-errors]').exists({ count: 1 });
      assert
        .dom('[data-test-first-name-errors] [data-test-error]')
        .exists({ count: 1 });

      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-type]'
        )
        .hasText('native');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-value]'
        )
        .hasNoText();
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error]:first-child [data-test-error-message]'
        )
        .hasText('This is a custom error message');
    });

    test('validation errors mark the control as invalid', async function (assert) {
      const data: TestFormData = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required data-test-first-name />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      await click('[data-test-submit]');

      assert.dom('[data-test-first-name]').hasAria('invalid', 'true');
    });

    test('native validation errors are merged with custom validation errors', async function (assert) {
      const data = { firstName: 'foo123', lastName: 'Smith' };
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
        firstName.toLowerCase().startsWith('foo')
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
            <field.Input required pattern="^[A-Za-z]+$" data-test-first-name />
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
        .exists({ count: 3 });

      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-type]'
        )
        .hasText('native');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-value]'
        )
        .hasText('foo123');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-message]'
        )
        .hasAnyText(); // validation error message is browser and locale dependant, so testing against actual message would be very brittle.

      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="1"] [data-test-error-type]'
        )
        .hasText('uppercase');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="1"] [data-test-error-value]'
        )
        .hasText('foo123');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="1"] [data-test-error-message]'
        )
        .hasText('First name must be upper case!');

      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="2"] [data-test-error-type]'
        )
        .hasText('notFoo');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="2"] [data-test-error-value]'
        )
        .hasText('foo123');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="2"] [data-test-error-message]'
        )
        .hasText('Foo is an invalid first name!');

      assert.dom('[data-test-last-name-errors]').doesNotExist();
    });

    test('no validation errors render when form data is valid', async function (assert) {
      const data = { firstName: 'John', lastName: 'Smith' };
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
        firstName.toLowerCase().startsWith('foo')
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
            <field.Input required pattern="^[A-Za-z]+$" data-test-first-name />
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

      assert.dom('[data-test-first-name-errors]').doesNotExist();
      assert.dom('[data-test-last-name-errors]').doesNotExist();
    });

    test('opt out of native validation using @ignoreNativeValidation', async function (assert) {
      const data: TestFormData = { firstName: 'john' };
      const formValidateCallback = ({ firstName }: TestFormData) =>
        firstName?.charAt(0).toUpperCase() !== firstName?.charAt(0)
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

      await render(<template>
        <HeadlessForm
          @data={{data}}
          @validate={{formValidateCallback}}
          @ignoreNativeValidation={{true}}
          as |form|
        >
          <form.Field @name="firstName" as |field|>
            <field.Label>First Name</field.Label>
            <field.Input required pattern="^[A-Za-z]+$" data-test-first-name />
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
            <field.Input required data-test-last-name />
            <field.Errors data-test-last-name-errors />
          </form.Field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      await click('[data-test-submit]');

      assert
        .dom('[data-test-first-name-errors] [data-test-error]')
        .exists({ count: 1 });

      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-type]'
        )
        .hasText('uppercase');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-value]'
        )
        .hasText('john');
      assert
        .dom(
          '[data-test-first-name-errors] [data-test-error="0"] [data-test-error-message]'
        )
        .hasText('First name must be upper case!');

      assert.dom('[data-test-last-name-errors]').doesNotExist();
    });

    module(`@validateOn`, function () {
      module('@validateOn=focusout', function () {
        test('validation errors are exposed as field.Errors on focusout', async function (assert) {
          const data: TestFormData = {};

          await render(<template>
            <HeadlessForm @data={{data}} @validateOn="focusout" as |form|>
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input
                  required
                  pattern="^[A-Za-z]+$"
                  data-test-first-name
                />
                <field.Errors data-test-first-name-errors />
              </form.Field>
              <form.Field @name="lastName" as |field|>
                <field.Label>Last Name</field.Label>
                <field.Input
                  required
                  pattern="^[A-Za-z]+$"
                  data-test-last-name
                />
                <field.Errors required data-test-last-name-errors />
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

          await fillIn('[data-test-first-name]', '123');

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
        test('validation errors are exposed as field.Errors on change', async function (assert) {
          const data: TestFormData = {};

          await render(<template>
            <HeadlessForm @data={{data}} @validateOn="change" as |form|>
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input
                  required
                  pattern="^[A-Za-z]+$"
                  data-test-first-name
                />
                <field.Errors data-test-first-name-errors />
              </form.Field>
              <form.Field @name="lastName" as |field|>
                <field.Label>Last Name</field.Label>
                <field.Input
                  required
                  pattern="^[A-Za-z]+$"
                  data-test-last-name
                />
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

          await fillIn('[data-test-first-name]', '123');

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
    });

    module(`@revalidateOn`, function () {
      module('@revalidateOn=focusout', function () {
        test('validation errors are exposed as field.Errors on focusout', async function (assert) {
          const data: TestFormData = {};

          await render(<template>
            <HeadlessForm @data={{data}} @revalidateOn="focusout" as |form|>
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input
                  required
                  pattern="^[A-Za-z]+$"
                  data-test-first-name
                />
                <field.Errors data-test-first-name-errors />
              </form.Field>
              <form.Field @name="lastName" as |field|>
                <field.Label>Last Name</field.Label>
                <field.Input
                  required
                  pattern="^[A-Za-z]+$"
                  data-test-last-name
                />
                <field.Errors data-test-last-name-errors />
              </form.Field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          assert
            .dom('[data-test-first-name-errors]')
            .doesNotExist(
              'validation errors are not rendered before before form is filled in'
            );
          assert
            .dom('[data-test-last-name-errors]')
            .doesNotExist(
              'validation errors are not rendered before before form is filled in'
            );

          await fillIn('[data-test-first-name]', '123');

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
        test('validation errors are revalidated on change', async function (assert) {
          const data: TestFormData = {};

          await render(<template>
            <HeadlessForm @data={{data}} @revalidateOn="change" as |form|>
              <form.Field @name="firstName" as |field|>
                <field.Label>First Name</field.Label>
                <field.Input
                  required
                  pattern="^[A-Za-z]+$"
                  data-test-first-name
                />
                <field.Errors data-test-first-name-errors />
              </form.Field>
              <form.Field @name="lastName" as |field|>
                <field.Label>Last Name</field.Label>
                <field.Input
                  required
                  pattern="^[A-Za-z]+$"
                  data-test-last-name
                />
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

          await fillIn('[data-test-first-name]', '123');

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
    });
  }
);
