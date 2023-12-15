import Model, { attr } from '@ember-data/model';

export default class UserModel extends Model {
  @attr('string') firstName?: string;
  @attr('string') lastName?: string;
  @attr('string') gender?: 'male' | 'female' | 'other';
  @attr('string') country?: string;
  @attr('string') comments?: string;
  @attr('string') acceptTerms?: boolean;
  @attr('string') age?: number;
}

declare module 'ember-data/types/registries/model' {
  export default interface ModelRegistry {
    user: UserModel;
  }
}
