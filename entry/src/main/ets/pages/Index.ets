import { BaseRouter, FullColumn } from '@my/base';

@Entry
@Component
struct Index {

  build() {
    Navigation(BaseRouter.getStack()) {
      FullColumn() {
        Button('DialogPage')
          .onClick(() => {
            BaseRouter.pushPath({ name: 'dialog/page' });
          });
      }
    }
    .height('100%')
    .width('100%');
  }
}