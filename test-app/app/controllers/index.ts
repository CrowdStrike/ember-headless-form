import Controller from '@ember/controller';

interface MyFormData {
  firstName?: string;
  lastName?: string;
  gender?: 'male' | 'female' | 'other';
  email?: string;
  accept_tos?: boolean;
  comment?: string;
}

export default class IndexController extends Controller {
  data: MyFormData = {};

  doSomething(data: MyFormData) {
    // eslint-disable-next-line no-console
    console.log('Form submitted 🚀', data);
  }
}
