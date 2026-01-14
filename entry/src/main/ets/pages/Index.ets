import { DialogUtils } from '@my/dialog';

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack();
  private uiContext: UIContext = AppStorage.get('UIContext') as UIContext;

  aboutToAppear(): void {
    AppStorage.setOrCreate('NavPathStack', this.pageStack);
  }

  build() {
    Navigation(this.pageStack) {
      Column({ space: 2 }) {
        Button('BindSheet')
          .onClick(() => {
            DialogUtils.openBindSheet();
          });
        Button('CustomDialog')
          .onClick(() => {
            DialogUtils.openCustomDialog();
          });
        Button('OverlayManager')
          .onClick(() => {
            DialogUtils.getOverlayManager();
          });
        Button('NavDialog')
          .onClick(() => {
            DialogUtils.navDialog();
          });
      };
    }
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%');
  }
}