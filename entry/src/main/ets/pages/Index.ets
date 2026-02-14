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
        Button('CommentPage')
          .onClick(() => {
            BaseRouter.pushPath({ name: 'comment/page' });
          });
      }
    }
    .height('100%')
    .width('100%');
  }
}