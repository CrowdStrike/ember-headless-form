/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { render } from '@ember/test-helpers';
import { module, test } from 'qunit';

import { HeadlessForm } from 'ember-headless-form';
import { setupRenderingTest } from 'test-app/tests/helpers';

module('Integration Component HeadlessForm > Glint', function (hooks) {
  setupRenderingTest(hooks);

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
        <form.Field @name="firstName" />
        {{! @glint-expect-error this is expected to be a glint error, as "lastName" does not exist on the type of @data! }}
        <form.Field @name="lastName" />
      </HeadlessForm>
    </template>);
  });

  test('@name argument only expects keys of @data w/ partial data', async function (assert) {
    assert.expect(0);
    const data: { firstName?: string } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        {{! this is valid }}
        <form.Field @name="firstName" />
        {{! @glint-expect-error this is expected to be a glint error, as "lastName" does not exist on the type of @data! }}
        <form.Field @name="lastName" />
      </HeadlessForm>
    </template>);
  });

  test('@name argument w/ an untyped @data errors', async function (assert) {
    assert.expect(0);
    const data = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        {{! @glint-expect-error this is expected to be a glint error, as "lastName" does not exist on the type of @data! }}
        <form.Field @name="firstName" />
      </HeadlessForm>
    </template>);
  });

  test('@name argument can only be used for string-types keys', async function (assert) {
    assert.expect(0);
    const data: { foo?: string; 0?: number } = {};

    await render(<template>
      <HeadlessForm @data={{data}} as |form|>
        <form.Field @name="foo" />
        {{! @glint-expect-error this is expected to be a glint error, as 0 is a valid key of data, but we also require it to be a string! }}
        <form.Field @name={{0}} />
      </HeadlessForm>
    </template>);
  });
});
