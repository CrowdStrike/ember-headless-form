import Controller from '@ember/controller';

import { object, string } from 'yup';

interface FormData {
  name?: string;
  value?: string;
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export default class IndexController extends Controller {
  data: FormData = {};

  get createFormSchema() {
    return object({
      name: string()
        .required('Name is required')
        .max(20, 'Max length is 20 characters'),
      value: string()
        .required('Value is required')
        .max(64, 'Max length is 64 characters')
        .test(
          'async-value-check',
          'No reserved words',
          async (value, testContext) => {
            // eslint-disable-next-line no-console
            console.log('async validator:', { value, testContext });

            await sleep(4000);

            if (['reserved', 'invalid', 'special'].includes(value)) {
              return false;
            }

            return true;
          }
        ),
    });
  }

  submit(data: FormData) {
    // eslint-disable-next-line no-console
    console.log('Form submitted 🚀', JSON.stringify(data, null, 2));
  }
}
