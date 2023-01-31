/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { tracked } from '@glimmer/tracking';
import { blur, click, fillIn, render, rerender } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { on } from '@ember/modifier';

import HeadlessForm from 'ember-headless-form/components/headless-form';
import sinon from 'sinon';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { RenderingTestContext } from '@ember/test-helpers';
import type {
  FormValidateCallback,
  FieldValidateCallback,
  ErrorRecord,
  ValidationError,
} from 'ember-headless-form/components/-private/types';

module(
  'Integration Component HeadlessForm > Custom Controls',
  function (hooks) {
    setupRenderingTest(hooks);

    interface TestFormData {
      date?: Date;
    }

    const days = new Array(31).fill(0).map((_v, index) => index + 1);
    const months = new Array(12).fill(0).map((_v, index) => index + 1);
    const years = new Array(20).fill(0).map((_v, index) => index + 2023);
    const CustomDateControl = <template>
      <fieldset>
        <legend>Date</legend>
        <label for="date-day">Day:</label>
        <select id="date-day" data-test-day>
          {{#each days as |day|}}
            <option value="{{day}}">{{day}}</option>
          {{/each}}
        </select>
        <label for="date-month">Month:</label>
        <select id="date-month" data-test-month>
          {{#each months as |month|}}
            <option value="{{month}}">{{month}}</option>
          {{/each}}
        </select>
        <label for="date-year">Year:</label>
        <select id="date-year" data-test-year>
          {{#each years as |year|}}
            <option value="{{year}}">{{year}}</option>
          {{/each}}
        </select>
      </fieldset>
    </template>;

    test('triggerValidation allows wiring up arbitrary triggers for validation', async function (assert) {
      const data: TestFormData = {};
      const validateCallback = sinon.fake.returns([
        { type: 'invalid-date', value: undefined, message: 'Invalid Date!' },
      ]);

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          <form.field @name="date" @validate={{validateCallback}} as |field|>
            <CustomDateControl />
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
        validateCallback.calledWith(undefined, 'date', data),
        '@validate is called with form data'
      );

      assert
        .dom('[data-test-date-errors]')
        .exists({ count: 1 }, 'validation errors appear when validation fails');
    });
  }
);
