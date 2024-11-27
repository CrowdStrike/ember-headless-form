---
title: Resetting state
order: 6
---

# Resetting form state

As explained in the chapter for [Updating data](./data#updating-data), form state consists of the original immutable data passed to `@data` and "dirty" changed state. To keep the form component in place but get rid of the dirty state, you need to explicitly call a `reset` action on the form. There are different ways to do that:

- use "the platform" and make the user click on a `<button type="reset">`
- use the yielded `reset` action

For the latter case, this is easy to do when the place where you want to call `reset` is within the block of `<HeadlessForm as |form|>`. For example you can pass it to the `on` modifier, is in `{{on "click form.reset}}`.

However there is another interesting use case where you might want to reset form state from "outside" the component, for example in a controller action. The problem here is that you do not have access to the yielded `reset` action there.
But you can follow the following pattern to solve that:

- create a function/method that receives the `reset` action (it's just a function) and assign it to the context where you will later be able to access it, like the controller for example
- invoke that function as a helper (in modern Ember, helpers are really just functions) within the form template block where you have access to the scope of the yielded `form` API
- call this registered reset function whenever you need to

Note that besides resetting dirty data, the form will also reset any [validation](../validation) state and errors it might had before!
