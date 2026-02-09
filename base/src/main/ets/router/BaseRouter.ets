export class BaseRouter {

  private static pathStack: NavPathStack = new NavPathStack();

  private constructor() {
  }

  static getStack(): NavPathStack {
    return BaseRouter.pathStack;
  }

  static pushPath(info: NavPathInfo, animated?: boolean): void {
    BaseRouter.pathStack.pushPath(info, animated);
  }

  static pushDestination(info: NavPathInfo, animated?: boolean): Promise<void> {
    return BaseRouter.pathStack.pushDestination(info, animated);
  }

  static pushPathByName(name: string, param: ESObject, animated?: boolean): void {
    BaseRouter.pathStack.pushPathByName(name, param, animated);
  }

  static pushDestinationByName(name: string, param: Object, animated?: boolean): Promise<void> {
    return BaseRouter.pathStack.pushDestinationByName(name, param, animated);
  }

  static replacePath(info: NavPathInfo, animated?: boolean): void {
    BaseRouter.pathStack.replacePath(info, animated);
  }

  static replaceDestination(info: NavPathInfo, options?: NavigationOptions): Promise<void> {
    return BaseRouter.pathStack.replaceDestination(info, options);
  }

  static replacePathByName(name: string, param: Object, animated?: boolean): void {
    BaseRouter.pathStack.replacePathByName(name, param, animated);
  }

  static removeByIndexes(indexes: Array<number>): number {
    return BaseRouter.pathStack.removeByIndexes(indexes);
  }

  static removeByName(name: string): number {
    return BaseRouter.pathStack.removeByName(name);
  }

  static removeByNavDestinationId(navDestinationId: string): boolean {
    return BaseRouter.pathStack.removeByNavDestinationId(navDestinationId);
  }

  static pop(animated?: boolean): Optional<NavPathInfo> {
    return BaseRouter.pathStack.pop(animated);
  }

  static popToName(name: string, animated?: boolean): number {
    return BaseRouter.pathStack.popToName(name, animated);
  }

  static popToIndex(index: number, animated?: boolean): void {
    BaseRouter.pathStack.popToIndex(index, animated);
  }

  static clear(animated?: boolean): void {
    BaseRouter.pathStack.clear(animated);
  }

  static getAllPathName(): Array<string> {
    return BaseRouter.pathStack.getAllPathName();
  }

  static getIndexByName(name: string): Array<number> {
    return BaseRouter.pathStack.getIndexByName(name);
  }

  static size(): number {
    return BaseRouter.pathStack.size();
  }

  static disableAnimation(value: boolean): void {
    BaseRouter.pathStack.disableAnimation(value);
  }

  static setInterception(interception: NavigationInterception): void {
    BaseRouter.pathStack.setInterception(interception);
  }

  static getPathStack(): Array<NavPathInfo> {
    return BaseRouter.pathStack.getPathStack();
  }

  static setPathStack(pathStack: Array<NavPathInfo>, animated?: boolean): void {
    BaseRouter.pathStack.setPathStack(pathStack, animated);
  }


}