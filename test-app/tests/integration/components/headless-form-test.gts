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

    // Unfortunately this test does not work due to `render` throwing in a deferred way (not covered by its returned promise)
    // See https://github.com/emberjs/ember-test-helpers/issues/310
    // keeping this still here to capture the intended behaviour (which works!), and for Glint type checking
    skip('input throws for type handled by dedicated component', async function (assert) {
      const data = { checked: false };

      assert.rejects(
        render(<template>
          <HeadlessForm @data={{data}} as |form|>
            <form.field @name="checked" as |field|>
              {{! @glint-expect-error }}
              <field.input @type="checkbox" />
            </form.field>
          </HeadlessForm>
        </template>)
      );
    });
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

  module('data', function () {
    module('data down', function () {
      test('data is passed to form controls', async function (assert) {
        const data = { firstName: 'Tony', lastName: 'Ward', acceptTerms: true };

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
            <form.field @name="acceptTerms" as |field|>
              <field.label>Terms accepted</field.label>
              <field.checkbox data-test-terms />
            </form.field>
          </HeadlessForm>
        </template>);

        assert.dom('input[data-test-first-name]').hasValue('Tony');
        assert.dom('input[data-test-last-name]').hasValue('Ward');
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

  module('Glint', function () {
    // These tests are not testing any new run-time behaviour that isn't tested elsewhere already.
    // Rather they are here to make sure they pass glint checks, testing for their types constraints to work as expected
    // Note: @glint-expect-error behaves just as @ts-expect-error in that in surpresses an error when we *expect* it to error,
    // but it *also* fails when no expected error is actually present!

    test('@name argument only expects keys of @data', async function (assert) {
      assert.expect(0);
      const data = { firstName: 'Simon' };

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          {{! this is valid }}
          <form.field @name="firstName" />
          {{! @glint-expect-error this is expected to be a glint error! }}
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
          {{! @glint-expect-error this is expected to be a glint error! }}
          <form.field @name="lastName" />
        </HeadlessForm>
      </template>);
    });

    test('@name argument w/ an untyped @data errors', async function (assert) {
      assert.expect(0);
      const data = {};

      await render(<template>
        <HeadlessForm @data={{data}} as |form|>
          {{! @glint-expect-error this is expected to be a glint error! }}
          <form.field @name="firstName" />
        </HeadlessForm>
      </template>);
    });
  });
});
