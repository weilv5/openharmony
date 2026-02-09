export abstract class BaseModel {
  abstract toJson(): string;
}

export class BaseRouter {
  static getStack(): NavPathStack;

  static pushPath(info: NavPathInfo, animated?: boolean): void;

  static pushPathByName(name: string, param: ESObject, animated?: boolean): void;
}

export { FullColumn } from '../ets/component/FullColumn';