/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import {
  blur,
  focus,
  fillIn,
  click,
  render,
  triggerEvent,
} from '@ember/test-helpers';
import { module, test } from 'qunit';
import { on } from '@ember/modifier';
import Component from '@glimmer/component';
import { action } from '@ember/object';

import { HeadlessForm } from 'ember-headless-form';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';
import type { RenderingTestContext } from '@ember/test-helpers';

module(
  'Integration Component HeadlessForm > Custom Controls',
  function (hooks) {
    setupRenderingTest(hooks);

    interface TestFormData {
      custom?: string;
    }

    class CustomControl extends Component<{
      Element: HTMLInputElement;
      Args: {
        value?: string;
        onChange(value: string): void;
      };
    }> {
      @action
      handleInput(e: Event | InputEvent): void {
        this.args.onChange((e.target as HTMLInputElement).value);
      }

      <template>
        <input
          type="text"
          value={{@value}}
          data-test-custom-control
          {{on "change" this.handleInput}}
          ...attributes
        />
      </template>
    }

    test('value/setValue can be used to bind the control', async function (assert) {
      const data: TestFormData = { custom: 'foo' };
      const submitHandler = sinon.spy();

      await render(<template>
        <HeadlessForm @data={{data}} @onSubmit={{submitHandler}} as |form|>
          <form.field @name="custom" as |field|>
            <CustomControl
              @value={{field.value}}
              @onChange={{field.setValue}}
            />
          </form.field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      assert.dom('[data-test-custom-control]').hasValue('foo');

      await fillIn('[data-test-custom-control]', 'bar');
      await click('[data-test-submit]');

      assert.true(submitHandler.calledWith({ custom: 'bar' }));
    });

    test('yielded id can be used to connect label with custom control', async function (this: RenderingTestContext, assert) {
      const data: TestFormData = { custom: 'foo' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="custom" as |field|>
            <field.label>Custom</field.label>
            <CustomControl
              @value={{field.value}}
              @onChange={{field.setValue}}
              id={{field.id}}
            />
          </form.field>
          <button type="submit" data-test-submit>Submit</button>
        </HeadlessForm>
      </template>);

      assert.dom('[data-test-custom-control]').hasAttribute('id');

      const id = this.element.querySelector('input')?.id ?? '';

      assert
        .dom('label')
        .hasAttribute(
          'for',
          id,
          'label is attached to input by `for` attribute'
        );
    });

    module('validation', function () {
      test('yielded isInvalid can be used to mark validation state', async function (assert) {
        const data: TestFormData = { custom: 'foo' };
        const validateCallback = sinon.fake.returns([
          { type: 'invalidate', value: undefined, message: 'Invalid value!' },
        ]);

        await render(<template>
          <HeadlessForm @data={{data}} as |form|>
            <form.field
              @name="custom"
              @validate={{validateCallback}}
              as |field|
            >
              <CustomControl
                @value={{field.value}}
                @onChange={{field.setValue}}
                aria-invalid={{if field.isInvalid "true"}}
              />
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert.dom('[data-test-custom-control]').doesNotHaveAria('invalid');

        await click('[data-test-submit]');

        assert.dom('[data-test-custom-control]').hasAria('invalid', 'true');
      });

      test('yielded errorId can be used to connect errors with custom control', async function (this: RenderingTestContext, assert) {
        const data: TestFormData = { custom: 'foo' };
        const validateCallback = sinon.fake.returns([
          { type: 'invalidate', value: undefined, message: 'Invalid value!' },
        ]);

        await render(<template>
          <HeadlessForm @data={{data}} as |form|>
            <form.field
              @name="custom"
              @validate={{validateCallback}}
              as |field|
            >
              <CustomControl
                @value={{field.value}}
                @onChange={{field.setValue}}
                aria-errormessage={{if field.isInvalid field.errorId}}
              />
              <field.errors data-test-errors />
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        assert
          .dom('[data-test-custom-control]')
          .doesNotHaveAria('errormessage');

        await click('[data-test-submit]');

        const id = this.element.querySelector('[data-test-errors]')?.id ?? '';

        assert
          .dom('[data-test-custom-control]')
          .hasAria(
            'errormessage',
            id,
            'errors are associated to invalid input via aria-errormessage'
          );
      });

      test('triggerValidation allows wiring up arbitrary triggers for validation', async function (assert) {
        const data: TestFormData = { custom: 'foo' };
        const validateCallback = sinon.fake.returns([
          { type: 'invalidate', value: undefined, message: 'Invalid value!' },
        ]);

        await render(<template>
          <HeadlessForm @data={{data}} as |form|>
            <form.field
              @name="custom"
              @validate={{validateCallback}}
              as |field|
            >
              <CustomControl
                @value={{field.value}}
                @onChange={{field.setValue}}
              />
              <button
                type="button"
                {{on "click" field.triggerValidation}}
                data-test-validate
              >
                Validate now!
              </button>
              <field.errors data-test-date-errors />
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await click('[data-test-validate]');

        assert.true(
          validateCallback.calledWith('foo', 'custom', data),
          '@validate is called with form data'
        );

        assert
          .dom('[data-test-date-errors]')
          .exists(
            { count: 1 },
            'validation errors appear when validation fails'
          );
      });

      module('captureEvents', function () {
        test('captures blur events triggering validation without controls having name matching field name when @validateOn="focusout"', async function (assert) {
          const data: TestFormData = { custom: 'foo' };
          const validateCallback = sinon.fake.returns([
            {
              type: 'invalid-date',
              value: undefined,
              message: 'Invalid Date!',
            },
          ]);

          await render(<template>
            <HeadlessForm @data={{data}} @validateOn="focusout" as |form|>
              <form.field
                @name="custom"
                @validate={{validateCallback}}
                as |field|
              >
                <CustomControl
                  @value={{field.value}}
                  @onChange={{field.setValue}}
                  {{field.captureEvents}}
                />
                <field.errors data-test-date-errors />
              </form.field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          // the input that triggers the blur does *not* have a name that would allow headless-form to understand from which field this event is coming from
          // but applying {{captureEvents}} will make headless-form be able to assiciate it to the name of the field
          await focus('[data-test-custom-control');
          await blur('[data-test-custom-control');

          assert.true(
            validateCallback.calledWith('foo', 'custom', data),
            '@validate is called with form data'
          );

          assert
            .dom('[data-test-date-errors]')
            .exists(
              { count: 1 },
              'validation errors appear when validation fails'
            );
        });

        test('captures change events triggering validation without controls having name matching field name when @validateOn="change"', async function (assert) {
          const data: TestFormData = { custom: 'foo' };
          const validateCallback = sinon.fake.returns([
            {
              type: 'invalid-date',
              value: undefined,
              message: 'Invalid Date!',
            },
          ]);

          await render(<template>
            <HeadlessForm @data={{data}} @validateOn="change" as |form|>
              <form.field
                @name="custom"
                @validate={{validateCallback}}
                as |field|
              >
                <CustomControl
                  @value={{field.value}}
                  @onChange={{field.setValue}}
                  {{field.captureEvents}}
                />
                <field.errors data-test-date-errors />
              </form.field>
              <button type="submit" data-test-submit>Submit</button>
            </HeadlessForm>
          </template>);

          // the input that triggers the blur does *not* have a name that would allow headless-form to understand from which field this event is coming from
          // but applying {{captureEvents}} will make headless-form be able to assiciate it to the name of the field
          await triggerEvent('[data-test-custom-control', 'change');

          assert.true(
            validateCallback.calledWith('foo', 'custom', data),
            '@validate is called with form data'
          );

          assert
            .dom('[data-test-date-errors]')
            .exists(
              { count: 1 },
              'validation errors appear when validation fails'
            );
        });
      });

      test('captures blur/change events triggering re-/validation without controls having name matching field name when @validateOn="focusout" and @revalidateOn="change"', async function (assert) {
        const data: TestFormData = { custom: 'foo' };
        const validateCallback = sinon.fake.returns([
          { type: 'invalid-date', value: undefined, message: 'Invalid Date!' },
        ]);

        await render(<template>
          <HeadlessForm
            @data={{data}}
            @validateOn="focusout"
            @revalidateOn="change"
            as |form|
          >
            <form.field
              @name="custom"
              @validate={{validateCallback}}
              as |field|
            >
              <CustomControl
                @value={{field.value}}
                @onChange={{field.setValue}}
                {{field.captureEvents}}
              />
              <field.errors data-test-date-errors />
            </form.field>
            <button type="submit" data-test-submit>Submit</button>
          </HeadlessForm>
        </template>);

        await triggerEvent('[data-test-custom-control', 'change');

        assert.false(
          validateCallback.called,
          '@validate is not called until blur'
        );
        assert
          .dom('[data-test-date-errors]')
          .doesNotExist('validation errors do not exist until blur');

        await focus('[data-test-custom-control');
        await blur('[data-test-custom-control');

        assert.true(
          validateCallback.calledWith('foo', 'custom', data),
          '@validate is called with form data'
        );

        assert
          .dom('[data-test-date-errors]')
          .exists(
            { count: 1 },
            'validation errors appear when validation fails'
          );

        await triggerEvent('[data-test-custom-control', 'change');

        assert.true(
          validateCallback.calledTwice,
          '@validate is called again on change for revalidation, after initial validation has happened'
        );
      });
    });
  }
);
