---
title: Data flow
order: 3
---

# Data flow

## Passing data into the form

As shown in the example above, we have introduced the `@data` argument to our form component. It receives the _initial_ data, and as such can be omitted or be just an empty `{}` object.

For pre-populating the form, you would need to pass an object, whose keys match the `@name`s of the form's fields. This resembles how native [FormData](https://developer.mozilla.org/en-US/docs/Web/API/FormData) or traditional server-side processed forms work. So in our case, the properties `@data` has here are `firstName` and `lastName`.

> Note that by default the passed `@data` is treated as an immutable object, following Ember's [DDAU](https://discuss.emberjs.com/t/readers-questions-what-is-meant-by-the-term-data-down-actions-up/15311) pattern. Which means when the user enters new data for any of the fields, it will **not** cause a mutation of `@data`! You can opt into [mutable behavior](#im-mutable-data) though, if you need to.

## Getting data out

The primary way of getting the user entered data back to your application code is by letting the user submit the form. If you pass an action to `@onSubmit`, it will be called when the user submitted the form successfully (means: after passing optional [validation](../validation)). It will then receive the _changed_ data as an argument, letting you decide what should happen, i.e. how to mutate your application state.

## Displaying data in the form

For more dynamic forms, you may need to read the data as it is being modified. You can do this by accessing the form's yielded `data` property within the block. It may look something like `{{form.data.firstName}}` if we use the above form as an example. 

## (Im-)mutable data

By default `@data` is immutable, i.e. the addon will only read from it. For handling the state of the _currently_ entered form data, a copy of that data is stored internally.

But there are use cases where you would want to mutate the data immediately when the user has changed some field. This is especially the case when the data is already an object that has some "buffering" capabilities, shielding its original source data from premature mutations, as with libraries like [ember-changeset](https://github.com/poteto/ember-changeset) or [ember-buffered-proxy](https://github.com/yapplabs/ember-buffered-proxy).

To do so, pass `@dataMode="mutable"` to the form component!

## Updating data

As we learned above, by default the form data passed as `@data` is immutable, and any changes due to the user entering or selecting new data as part of interacting with the form is stored as a separate copy, which we call "dirty" data here (as it deviates from the original data, but is not "persisted" yet). If you change `@data` (either by reassigning a whole new object or updating tracked properties), the form will automatically reflect those changes, i.e. form fields will update their value.

However, this will _not_ happen for any non-pristine fields, i.e. fields that have new user-entered dirty data, as this would mean irrevocably losing that data. But if that is what you want, you need to explicitly wipe out that dirty data by [resetting the form](./reset). So to keep an existing form in place, but just replace all of its data, you would need to do both reassigning new `@data` and resetting the dirty state!
