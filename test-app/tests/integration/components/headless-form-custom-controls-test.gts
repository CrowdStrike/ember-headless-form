/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { blur, focus, click, render, triggerEvent } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { on } from '@ember/modifier';

import HeadlessForm from 'ember-headless-form/components/headless-form';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';
import type { TemplateOnlyComponent } from '@ember/component/template-only';

module(
  'Integration Component HeadlessForm > Custom Controls',
  function (hooks) {
    setupRenderingTest(hooks);

    interface TestFormData {
      custom?: string;
    }

    // this is a mock of a custom control component, not yielded by headless-form itself
    const CustomControl: TemplateOnlyComponent<{
      Element: HTMLInputElement;
      Args: {
        value?: string;
        onChange(value: string): void;
      };
    }> = <template>
      <input
        type="text"
        value={{@value}}
        data-test-custom-control
        ...attributes
      />
    </template>;

    test('triggerValidation allows wiring up arbitrary triggers for validation', async function (assert) {
      const data: TestFormData = {};
      const validateCallback = sinon.fake.returns([
        { type: 'invalidate', value: undefined, message: 'Invalid value!' },
      ]);

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="custom" @validate={{validateCallback}} as |field|>
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
        validateCallback.calledWith(undefined, 'custom', data),
        '@validate is called with form data'
      );

      assert
        .dom('[data-test-date-errors]')
        .exists({ count: 1 }, 'validation errors appear when validation fails');
    });

    module('captureEvents', function () {
      test('captures blur events triggering validation without controls having name matching field name when @validateOn="blur"', async function (assert) {
        const data: TestFormData = {};
        const validateCallback = sinon.fake.returns([
          { type: 'invalid-date', value: undefined, message: 'Invalid Date!' },
        ]);

        await render(<template>
          <HeadlessForm @data={{data}} @validateOn="blur" as |form|>
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
          validateCallback.calledWith(undefined, 'custom', data),
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
        const data: TestFormData = {};
        const validateCallback = sinon.fake.returns([
          { type: 'invalid-date', value: undefined, message: 'Invalid Date!' },
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
          validateCallback.calledWith(undefined, 'custom', data),
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

    test('captures blur/change events triggering re-/validation without controls having name matching field name when @validateOn="blur" and @revalidateOn="change"', async function (assert) {
      const data: TestFormData = {};
      const validateCallback = sinon.fake.returns([
        { type: 'invalid-date', value: undefined, message: 'Invalid Date!' },
      ]);

      await render(<template>
        <HeadlessForm
          @data={{data}}
          @validateOn="blur"
          @revalidateOn="change"
          as |form|
        >
          <form.field @name="custom" @validate={{validateCallback}} as |field|>
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
        validateCallback.calledWith(undefined, 'custom', data),
        '@validate is called with form data'
      );

      assert
        .dom('[data-test-date-errors]')
        .exists({ count: 1 }, 'validation errors appear when validation fails');

      await triggerEvent('[data-test-custom-control', 'change');

      assert.true(
        validateCallback.calledTwice,
        '@validate is called again on change for revalidation, after initial validation has happened'
      );
    });
  }
);
