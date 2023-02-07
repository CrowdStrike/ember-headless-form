import { find, triggerEvent } from '@ember/test-helpers';

/**
 * Fill the provided text into the `value` property of the selected form element, similar to `fillIn`, but *without* implicitly triggering a `change` event.
 * This mimics the behavior of a user typing data into an input without yet focusing out of it. Browsers will only trigger a `change` event when focusing
 * out of the element, not while typing!
 *
 * `fillIn` will basically simulate entering the data *and* kinda focusing out (as it triggers `change`, however not `focusout`, which is impossible to achieve as a real user),
 * while this helper does only the former.
 */
export async function input(selector: string, value: string): Promise<void> {
  const el = find(selector);

  if (!el) {
    throw new Error(`No element found for selector ${selector}`);
  }

  if (!(el instanceof HTMLInputElement || el instanceof HTMLTextAreaElement)) {
    throw new Error(`Invalid element for \`input\` helper.`);
  }

  el.value = value;
  await triggerEvent(el, 'input');
}
