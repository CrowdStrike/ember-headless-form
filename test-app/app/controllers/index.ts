import Controller from '@ember/controller';

interface MyFormData {
  name: string;
}

export default class IndexController extends Controller {
  data: MyFormData = {
    name: 'Simon',
  };

  doSomething(data: MyFormData) {
    console.log('Form submitted 🚀', data);
  }
}
