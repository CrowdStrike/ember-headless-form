import { getOwner } from '@ember/application';
import Helper from '@ember/component/helper';

import type { Registry } from '@ember/service';

interface Signature<Key extends keyof Registry> {
  Return: Registry[Key];
  Args: {
    Positional: [serviceName: Key];
  };
}

export default class GetService<Key extends keyof Registry> extends Helper<
  Signature<Key>
> {
  compute([name]: [Key]): Registry[Key] {
    let owner = getOwner(this);

    return owner.lookup(`service:${name}`) as Registry[Key];
  }
}
