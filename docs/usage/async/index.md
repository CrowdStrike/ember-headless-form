---
title: Async state
order: 7
---

# Managing asynchronous state

ember-headless-form knows about two events that can be asynchronous:

- **validation** will often be synchronous, but you can also define [asynchronous validations](../../validation/custom-validation.md#asynchronous-validation) for e.g. validating data on the server
- **submission** is most often asynchronous when e.g. sending a `POST` request with your form data to the server

To make the form aware of the asynchronous submission process, you just need to return a Promise from the submit callback passed to [`@onSubmit`](../data/index.md#getting-data-out).

ember-headless-form will then make the async state of both these events available to you in the template. This allows for use cases like

- disabling the submit button while a submission is ongoing
- showing a loading indicator while submission or validation is pending
- rendering the results of the (either successful or failed) submission, after it is resolved/rejected

To enable these, the form component is yielding `validationState` and `submissionState` objects with these properties:

- `isPending`
- `isResolved`
- `isRejected`
- `value` (when resolved)
- `error` (when rejected)

These derived properties are fully reactive and typed, as these are provided by the excellent [ember-async-data](https://github.com/tracked-tools/ember-async-data) addon. Refer to their documentation for additional details!
