# How To Contribute

## Installation

* `git clone <repository-url>`
* `cd ember-headless-form`
* `pnpm install`

## Linting

* `pnpm lint`
* `pnpm lint:fix`

## Developing

To develop in this monorepo you can simply run:

 * `pnpm start`

from the root directory.

This will:

 * Build all of the `packages/*` and watch them for changes
 * Build the docs app and the tests app and serve them
 * Automatically sync changes from the `packages/*` to the served apps so 
   that they are always up to date.

You can now visit:

 * The docs app at http://localhost:4201/
 * The tests app at http://localhost:4202/tests

If you don't need to run both apps you can save a little of your local 
compute by running:

 * `start:only:docs` and visiting http://localhost:4201/
 * `start:only:tests` and visiting http://localhost:4202/tests

These commands will still build and watch the `packages/*` and sync changes
to the running app. Don't run both `only` tasks together as this will cause
issues - if you want to run both apps simply use `pnpm start`.

## Running tests

You can run the tests with the following commands:

 * `pnpm test`
 * `pnpm test:docs`

For more information on using ember-cli, visit [https://cli.emberjs.com/release/](https://cli.emberjs.com/release/).
