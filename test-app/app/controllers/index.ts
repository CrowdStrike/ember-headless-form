import Controller from '@ember/controller';

interface MyFormData {
  firstName?: string;
  lastName?: string;
  gender?: 'male' | 'female' | 'other';
  likes?: ('red' | 'green' | 'blue')[];
  email?: string;
  country?: string;
  accept_tos?: boolean;
  comment?: string;
}

export default class IndexController extends Controller {
  data: MyFormData = {};

  doSomething(data: MyFormData) {
    // eslint-disable-next-line no-console
    console.log('Form submitted 🚀', JSON.stringify(data, null, 2));
  }
}
