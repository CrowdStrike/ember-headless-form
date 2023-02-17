import { modifier } from 'ember-modifier';

export interface CaptureEventsModifierSignature {
  Element: HTMLElement;
  Args: {
    Named: {
      /*
       * @internal
       */
      event: 'focusout' | 'change';

      /*
       * @internal
       */
      triggerValidation(): void;
    };
  };
}

const CaptureEventsModifier = modifier<CaptureEventsModifierSignature>(
  (element, _pos, { event, triggerValidation }) => {
    element.addEventListener(event, triggerValidation, { passive: true });

    return () => {
      element.removeEventListener(event, triggerValidation);
    };
  }
);

export default CaptureEventsModifier;
