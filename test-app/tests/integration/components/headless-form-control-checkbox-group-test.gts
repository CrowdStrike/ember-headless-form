/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { click, render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { RenderingTestContext } from '@ember/test-helpers';

module('Integration Component HeadlessForm > CheckboxGroup', function (hooks) {
  setupRenderingTest(hooks);

  test('field yields checkboxgroup component', async function (assert) {
    const data: { choices: string[] } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choices" as |field|>
          <field.CheckboxGroup class="my-checkbox-group" data-test-checkboxgroup>
            Some content
          </field.CheckboxGroup>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('form')
      .hasText('Some content', 'checkboxgroup renders block content');

    assert
      .dom('form > div')
      .exists('checkbox component renders as a div')
      .hasClass('my-checkbox-group', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-checkboxgroup',
        '',
        'it accepts arbitrary HTML attributes'
      )
      .hasAttribute('role', 'group', 'it has a group role');
  });

  test('checkboxgroup yields label component', async function (this: RenderingTestContext, assert) {
    const data: { choices?: string[] } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choices" as |field|>
          <field.CheckboxGroup data-test-checkbox as |group|>
            <group.Label class="my-label" data-test-checkbox-label>My Group</group.Label>
          </field.CheckboxGroup>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('form > div > div')
      .hasText('My Group', 'it renders block content')
      .hasClass('my-label', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-checkbox-label',
        '',
        'it accepts arbitrary HTML attributes'
      );

    assert.dom('[data-test-checkbox-label]').hasAttribute(
      'id',
      // copied from https://ihateregex.io/expr/uuid/
      /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/,
      'input has id with dynamically generated uuid'
    );

    const id =
      this.element.querySelector('[data-test-checkbox-label]')?.id ?? '';

    assert
      .dom('[data-test-checkbox]')
      .hasAria(
        'labelledby',
        id,
        'label is connected to checkbox by `aria-labelledby` attribute'
      );
  });

  test('checkboxgroup yields checkbox component', async function (assert) {
    const data: { choices?: string[] } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choices" as |field|>
          <field.CheckboxGroup as |group|>
            <group.Checkbox @value="foo" as |checkbox|>
              <checkbox.Label class="my-label" data-test-label>Foo</checkbox.Label>
            </group.Checkbox>
          </field.CheckboxGroup>
        </form.Field>
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

  test('checkbox yields label component', async function (assert) {
    const data: { choices?: string[] } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choices" as |field|>
          <field.CheckboxGroup as |group|>
            <group.Checkbox @value="foo" as |checkbox|>
              <checkbox.Label class="my-label" data-test-label>Foo</checkbox.Label>
            </group.Checkbox>
          </field.CheckboxGroup>
        </form.Field>
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

  test('checkbox yields input component', async function (assert) {
    const data: { choices?: string[] } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choices" as |field|>
          <field.CheckboxGroup as |group|>
            <group.Checkbox @value="foo" as |checkbox|>
              <checkbox.Input class="my-input" data-test-checkbox />
            </group.Checkbox>
          </field.CheckboxGroup>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('input')
      .exists('render an input')
      .hasAttribute('type', 'checkbox')
      .hasAttribute('name', 'choices')
      .hasValue('foo')
      .hasClass('my-input', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-checkbox',
        '',
        'it accepts arbitrary HTML attributes'
      );
  });

  test('label and input are connected', async function (this: RenderingTestContext, assert) {
    const data: { choices?: string[] } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choices" as |field|>
          <field.CheckboxGroup as |group|>
            <group.Checkbox @value="foo" as |checkbox|>
              <checkbox.Input />
              <checkbox.Label>Foo</checkbox.Label>
            </group.Checkbox>
          </field.CheckboxGroup>
        </form.Field>
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
      .hasAttribute('for', id, 'label is attached to input by `for` attribute');
  });

  test('checked property is mapped correctly to @data', async function (assert) {
    const data: { choices?: string[] } = { choices: ['bar'] };

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choices" as |field|>
          <field.CheckboxGroup as |group|>
            <group.Checkbox @value="foo" as |checkbox|>
              <checkbox.Input data-test-checkbox1 />
              <checkbox.Label>Foo</checkbox.Label>
            </group.Checkbox>
            <group.Checkbox @value="bar" as |checkbox|>
              <checkbox.Input data-test-checkbox2 />
              <checkbox.Label>Bar</checkbox.Label>
            </group.Checkbox>
          </field.CheckboxGroup>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert.dom('input[data-test-checkbox1]').isNotChecked();
    assert.dom('input[data-test-checkbox2]').isChecked();
  });

  test('validation errors are connected to checkboxgroup', async function (this: RenderingTestContext, assert) {
    const data: { choices?: string[] } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choices" as |field|>
          <field.CheckboxGroup data-test-checkboxgroup as |group|>
            <group.Checkbox @value="foo" as |checkbox|>
              <checkbox.Input required data-test-checkbox1 />
              <checkbox.Label>Foo</checkbox.Label>
            </group.Checkbox>
            <group.Checkbox @value="bar" as |checkbox|>
              <checkbox.Input required data-test-checkbox2 />
              <checkbox.Label>Bar</checkbox.Label>
            </group.Checkbox>
          </field.CheckboxGroup>
          <field.Errors data-test-errors />
        </form.Field>
        <button type="submit" data-test-submit>Submit</button>

      </HeadlessForm>
    </template>);

    assert.dom('[data-test-errors]').doesNotExist();
    assert
      .dom('[data-test-checkboxgroup]')
      .doesNotHaveAria(
        'describedby',
        'aria-desribedby is not applied when no errors are present'
      );

    await click('[data-test-submit]');

    assert
      .dom('[data-test-errors]')
      .exists()
      .hasAttribute(
        'id',
        // copied from https://ihateregex.io/expr/uuid/
        /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/,
        'errors element has id with dynamically generated uuid'
      );

    const id = this.element.querySelector('[data-test-errors]')?.id ?? '';

    assert
      .dom('[data-test-checkboxgroup]')
      .hasAria(
        'describedby',
        id,
        'aria-desribedby is applied when errors are present'
      );
  });
});
