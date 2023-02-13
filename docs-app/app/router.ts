import { registerDestructor } from '@ember/destroyable';
import EmberRouter from '@embroider/router';

import { addDocfyRoutes } from '@docfy/ember';
import config from 'docs-app/config/environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;

  constructor(...args: [object]) {
    super(...args);

    let scroll = () => window.scrollTo(0, 0);

    this.on('routeDidChange', scroll);
    registerDestructor(this, () => {
      this.off('routeDidChange', scroll);
    });
  }
}

Router.map(function () {
  addDocfyRoutes(this);
});
