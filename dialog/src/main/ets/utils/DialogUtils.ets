import { ComponentContent } from '@kit.ArkUI';
import { BindSheet, CustomDialog, OverlayManagerDailog } from '../components/DialogComponents';
import { BindSheetParams, CustomDialogParams, OverlayManagerParams, NavDialogParams } from '../model/DialogParams';

export class DialogUtils {

  static async openBindSheet(uiContext?: UIContext) {
    uiContext = uiContext ?? (AppStorage.get('UIContext') as UIContext);
    const bindSheetParams = BindSheetParams.newInstance();
    bindSheetParams.title = 'bindSheetTitle';
    bindSheetParams.text = 'bindSheetText';
    bindSheetParams.callback = (code: number) => {
      console.log(`bindSheet callback code: ${code}`);
    };
    const bindSheetContent: ComponentContent<BindSheetParams> =
      new ComponentContent(uiContext, wrapBuilder(BindSheet), bindSheetParams);
    const sheetOptions: SheetOptions = {
      height: SheetSize.MEDIUM,
      preferType: SheetType.BOTTOM,
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        // 半模态页面交互式关闭回调函数
        console.log('bindSheet will close');
        sheetDismiss.dismiss();
      },
      onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
        // 半模态页面的交互式关闭回调函数。允许开发者注册，以获取关闭操作的类型，并决定是否关闭半模态状态
        console.info(`bindSheet closed reason: ${dismissSheetAction.reason}`);
        dismissSheetAction.dismiss();
      },
      onWillSpringBackWhenDismiss: ((springBackAction: SpringBackAction) => {
        // 半模态页面交互式关闭前控制回弹函数。允许开发者注册，以控制半模态页面交互式关闭时的回弹效果
        console.info('bindSheet spring back');
        springBackAction.springBack();
      })
    };
    try {
      await uiContext.openBindSheet(bindSheetContent, sheetOptions);
      console.info('openBindSheet success');
    } catch (err) {
      console.error(`openBindSheet error: ${err.code} ${err.message}`);
    }
  }

  static async openCustomDialog(uiContext?: UIContext) {
    uiContext = uiContext ?? (AppStorage.get('UIContext') as UIContext);
    const customDialogParams = CustomDialogParams.newInstance();
    customDialogParams.text = 'customDialogText';
    const customDialogcontent = new ComponentContent(uiContext, wrapBuilder(CustomDialog), customDialogParams);
    try {
      await uiContext.getPromptAction().openCustomDialog(customDialogcontent);
      console.info('customDialog success');
    } catch (err) {
      console.error(`customDialog error: ${err.code} ${err.message}`);
    }
  }

  static async getOverlayManager(uiContext?: UIContext) {
    uiContext = uiContext ?? (AppStorage.get('UIContext') as UIContext);
    const overlayManagerParams = OverlayManagerParams.newInstance();
    overlayManagerParams.text = 'overlayManagerText';
    overlayManagerParams.close = () => {
      try {
        uiContext?.getOverlayManager().removeComponentContent(customDialogContent);
        console.info('overlayManager close success');
      } catch (err) {
        console.error(`overlayManager close error: ${err.code} ${err.message}`);
      }
    }
    const customDialogContent = new ComponentContent(uiContext, wrapBuilder(OverlayManagerDailog), overlayManagerParams);
    try {
      uiContext.getOverlayManager().addComponentContent(customDialogContent);
      console.info('overlayManager success');
    } catch (err) {
      console.error(`overlayManager error: ${err.code} ${err.message}`);
    }
  }

  static navDialog(navPathStack?: NavPathStack) {
    navPathStack = navPathStack ?? (AppStorage.get('NavPathStack') as NavPathStack);
    const navDialogParams = NavDialogParams.newInstance();
    navDialogParams.text = 'navDialogText';
    navDialogParams.close = () => {
      navPathStack?.pop();
      console.info('navDialog close success');
    }
    try {
      navPathStack.pushPathByName('NavDialog', navDialogParams);
      console.info('navDialog success');
    } catch (err) {
      console.error(`navDialog error: ${err.code} ${err.message}`);
    }
  }
}
