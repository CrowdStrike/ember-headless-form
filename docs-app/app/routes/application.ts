import { getOwner } from '@ember/application';
import Route from '@ember/routing/route';
import { service } from '@ember/service';

import { setupHLJS } from '@crowdstrike/ember-oss-docs/utils/highlighting';
import { type ThemeManager, THEMES } from '@crowdstrike/ember-toucan-styles';

export default class Application extends Route {
  @service declare themeManager: ThemeManager;

  beforeModel() {
    this.themeManager.setup(THEMES.LIGHT);
  }

  afterModel() {
    setupHLJS(getOwner(this));
  }
}
