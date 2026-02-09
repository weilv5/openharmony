import {
  NavDialogParams,
  DialogParams
} from '../model/DialogParams';
import { DialogUtils } from '../utils/DialogUtils';

@Builder
export function Dialog(params: DialogParams) {
  if (DialogUtils.useBackground(params)) {
    Stack({ alignContent: Alignment.Center }) {
      DialogContent(params)
    }
    .onClick(() => {
      params.cancel?.()
    })
    .height('100%')
    .width('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
  } else {
    DialogContent(params)
  }
}

@Builder
function DialogContent(params: DialogParams) {
  Column({space: 30}) {
    Text(params.title)
      .fontSize(25)
      .fontWeight(FontWeight.Bold)
      .visibility(params.title ? Visibility.Visible : Visibility.None)
    Text(params.content)
      .fontSize(18)
      .visibility(params.content ? Visibility.Visible : Visibility.None)
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceEvenly }) {
      Button('Confirm')
        .onClick(() => {
          params.confirm?.()
        })
        .visibility(params.confirm ? Visibility.Visible : Visibility.None)
      Button('Cancel')
        .onClick(() => {
          params.cancel?.()
        })
        .visibility(params.cancel ? Visibility.Visible : Visibility.None)
    }
    .visibility((params.confirm || params.cancel) ? Visibility.Visible : Visibility.None)
  }
  .background(Color.White)
}

@Builder
export function DialogPageBuilder() {
  DialogPage();
}

@ComponentV2
struct DialogPage {
  @Local data: NavDialogParams = new NavDialogParams({});

  build() {
    NavDestination() {
      Dialog(this.data)
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context: NavDestinationContext) => {
      console.log('NavDialog onReady');
      this.data = context.pathInfo.param as NavDialogParams;
    });
  }
}