import { BindSheetParams, CustomDialogParams, OverlayManagerParams, NavDialogParams } from '../model/DialogParams';

@Builder
export function BindSheet(params: BindSheetParams) {
  Column() {
    Text(params.title)
      .fontSize(20)
      .margin({ bottom: 100 });
    Text(params.text)
      .fontSize(20)
      .margin({ bottom: 100 });
    Button('callback')
      .onClick(() => {
        params.callback?.(0);
      })
      .margin({ bottom: 100 });
  };
}

@Builder
export function CustomDialog(params: CustomDialogParams) {
  Column() {
    Text(params.text)
      .fontSize(20)
      .margin({ bottom: 100 });
  }
  .justifyContent(FlexAlign.Center)
  .backgroundColor(Color.White)
  .borderRadius(10)
  .height('30%')
  .width('80%');
}

@Builder
export function OverlayManagerDailog(params: OverlayManagerParams) {
  Stack({ alignContent: Alignment.Center }) {
    Column() {
      Text(params.text)
        .fontSize(20)
        .margin({ bottom: 100 });
      Button('Close').onClick(() => {
        params.close();
      }).width('30%');
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .height('30%')
    .width('80%');
  }
  .height('100%')
  .width('100%')
  .backgroundColor('rgba(0,0,0,0.5)');
}

@Builder
export function DialogPageBuilder() {
  DialogPage();
}

@ComponentV2
struct DialogPage {
  @Local data: NavDialogParams = NavDialogParams.newInstance();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text(this.data.text)
            .fontSize(20)
            .margin({ bottom: 100 });
          Button('Close').onClick(() => {
            this.data.close();
          }).width('30%');
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .height('30%')
        .width('80%');
      }.height('100%').width('100%');
    }
    .backgroundColor('rgba(0,0,0,0.5)')
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context: NavDestinationContext) => {
      console.log('NavDialog onReady');
      this.data = context.pathInfo.param as NavDialogParams;
    });
  }
}