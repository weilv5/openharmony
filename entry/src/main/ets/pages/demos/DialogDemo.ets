import { FullColumn } from '@my/base';
import { DialogUtils } from '@my/dialog';

@Builder
export function DialogPageBuilder() {
  DialogPage();
}

@ComponentV2
struct DialogPage {
  build() {
    NavDestination() {
      FullColumn() {
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
    };
  }
}