/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */

import { click, render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

import type { RenderingTestContext } from '@ember/test-helpers';

module('Integration Component HeadlessForm > Radio', function (hooks) {
  setupRenderingTest(hooks);

  test('field yields radiogroup component', async function (assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.RadioGroup class="my-radio-group" data-test-radiogroup>
            Some content
          </field.RadioGroup>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('form')
      .hasText('Some content', 'radiogroup renders block content');

    assert
      .dom('form > div')
      .exists('radio component renders as a div')
      .hasClass('my-radio-group', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-radiogroup',
        '',
        'it accepts arbitrary HTML attributes'
      )
      .hasAttribute('role', 'radiogroup', 'it has a radiogroup role');
  });

  test('radiogroup yields label component', async function (this: RenderingTestContext, assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.RadioGroup data-test-radiogroup as |group|>
            <group.Label class="my-label" data-test-radiogroup-label>My Group</group.Label>
          </field.RadioGroup>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('form > div > div')
      .hasText('My Group', 'it renders block content')
      .hasClass('my-label', 'it accepts custom HTML classes')
      .hasAttribute(
        'data-test-radiogroup-label',
        '',
        'it accepts arbitrary HTML attributes'
      );

    assert.dom('[data-test-radiogroup-label]').hasAttribute(
      'id',
      // copied from https://ihateregex.io/expr/uuid/
      /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/,
      'input has id with dynamically generated uuid'
    );

    const id =
      this.element.querySelector('[data-test-radiogroup-label]')?.id ?? '';

    assert
      .dom('[data-test-radiogroup]')
      .hasAria(
        'labelledby',
        id,
        'label is connected to radiogroup by `aria-labelledby` attribute'
      );
  });

  test('radiogroup yields radio component', async function (assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.RadioGroup as |group|>
            <group.Radio @value="foo" as |radio|>
              <radio.Label class="my-label" data-test-label>Foo</radio.Label>
            </group.Radio>
          </field.RadioGroup>
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

  test('radio yields label component', async function (assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.RadioGroup as |group|>
            <group.Radio @value="foo" as |radio|>
              <radio.Label class="my-label" data-test-label>Foo</radio.Label>
            </group.Radio>
          </field.RadioGroup>
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

  test('radio yields input component', async function (assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.RadioGroup as |group|>
            <group.Radio @value="foo" as |radio|>
              <radio.Input class="my-input" data-test-radio />
            </group.Radio>
          </field.RadioGroup>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert
      .dom('input')
      .exists('render an input')
      .hasAttribute('type', 'radio')
      .hasAttribute('name', 'choice')
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
        <form.Field @name="choice" as |field|>
          <field.RadioGroup as |group|>
            <group.Radio @value="foo" as |radio|>
              <radio.Input />
              <radio.Label>Foo</radio.Label>
            </group.Radio>
          </field.RadioGroup>
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
    const data: { choice?: string } = { choice: 'bar' };

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.RadioGroup as |group|>
            <group.Radio @value="foo" as |radio|>
              <radio.Input data-test-radio1 />
              <radio.Label>Foo</radio.Label>
            </group.Radio>
            <group.Radio @value="bar" as |radio|>
              <radio.Input data-test-radio2 />
              <radio.Label>Bar</radio.Label>
            </group.Radio>
          </field.RadioGroup>
        </form.Field>
      </HeadlessForm>
    </template>);

    assert.dom('input[data-test-radio1]').isNotChecked();
    assert.dom('input[data-test-radio2]').isChecked();
  });

  test('validation errors are connected to radiogroup', async function (this: RenderingTestContext, assert) {
    const data: { choice?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="choice" as |field|>
          <field.RadioGroup data-test-radiogroup as |group|>
            <group.Radio @value="foo" as |radio|>
              <radio.Input required data-test-radio1 />
              <radio.Label>Foo</radio.Label>
            </group.Radio>
            <group.Radio @value="bar" as |radio|>
              <radio.Input required data-test-radio2 />
              <radio.Label>Bar</radio.Label>
            </group.Radio>
          </field.RadioGroup>
          <field.Errors data-test-errors />
        </form.Field>
        <button type="submit" data-test-submit>Submit</button>

      </HeadlessForm>
    </template>);

    assert.dom('[data-test-errors]').doesNotExist();
    assert
      .dom('[data-test-radiogroup]')
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
      .dom('[data-test-radiogroup]')
      .hasAria(
        'describedby',
        id,
        'aria-desribedby is applied when errors are present'
      );
  });
});
