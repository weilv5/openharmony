import { ComponentContent } from '@kit.ArkUI';
import { BaseRouter } from '@my/base';
import { Dialog } from '../components/DialogComponents';
import { BindSheetParams, CustomDialogParams, OverlayManagerParams, NavDialogParams,
  DialogParams } from '../model/DialogParams';
import { DialogType } from '../model/DialogType';

export class DialogUtils {

  static useBackground(params: DialogParams): boolean {
    if (params.type === DialogType.OVERLAY || params.type === DialogType.NAV) {
      if (params instanceof OverlayManagerParams) {
        return params.useBackground;
      }
      if (params instanceof NavDialogParams) {
        return params.useBackground;
      }
      return false;
    }
    return false;
  }

  static async openBindSheet(uiContext?: UIContext) {
    uiContext = uiContext ?? (AppStorage.get('UIContext') as UIContext);
    const bindSheetParams = new BindSheetParams({
      title: 'bindSheetTitle',
      content: 'bindSheetContent',
      confirm: () => {
        console.log(`bindSheet confirm success`);
      },
      cancel: () => {
        console.log(`bindSheet cancel success`);
      }
    });
    const bindSheetContent: ComponentContent<BindSheetParams> =
      new ComponentContent(uiContext, wrapBuilder(Dialog), bindSheetParams);
    const sheetOptions: SheetOptions = {
      height: SheetSize.FIT_CONTENT,
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
    const customDialogParams = new CustomDialogParams({
      title: 'customDialogTitle',
      content: 'customDialogContent',
      confirm: () => {
        console.log(`customDialog confirm success`);
      },
      cancel: () => {
        console.log(`customDialog cancel success`);
      }
    });
    const customDialogContent = new ComponentContent(uiContext, wrapBuilder(Dialog), customDialogParams);
    try {
      await uiContext.getPromptAction().openCustomDialog(customDialogContent);
      console.info('customDialog success');
    } catch (err) {
      console.error(`customDialog error: ${err.code} ${err.message}`);
    }
  }

  static async getOverlayManager(uiContext?: UIContext) {
    uiContext = uiContext ?? (AppStorage.get('UIContext') as UIContext);
    const overlayManagerParams = new OverlayManagerParams({
      title: 'overlayManagerTitle',
      content: 'overlayManagerContent',
      confirm: () => {
        console.log(`overlayManager confirm success`);
      },
      cancel: () => {
        try {
          uiContext?.getOverlayManager().removeComponentContent(customDialogContent);
          console.info('overlayManager cancel success');
        } catch (err) {
          console.error(`overlayManager cancel error: ${err.code} ${err.message}`);
        }
      }
    });
    const customDialogContent = new ComponentContent(uiContext, wrapBuilder(Dialog), overlayManagerParams);
    try {
      uiContext.getOverlayManager().addComponentContent(customDialogContent);
      console.info('overlayManager success');
    } catch (err) {
      console.error(`overlayManager error: ${err.code} ${err.message}`);
    }
  }

  static navDialog(navPathStack?: NavPathStack) {
    navPathStack = navPathStack ?? BaseRouter.getStack();
    const navDialogParams = new NavDialogParams({
      title: 'navDialogTitle',
      content: 'navDialogContent',
      confirm: () => {
        console.log(`navDialog confirm success`);
      },
      cancel: () => {
        navPathStack?.pop();
        console.info('navDialog cancel success');
      }
    });
    try {
      navPathStack.pushPathByName('NavDialog', navDialogParams);
      console.info('navDialog success');
    } catch (err) {
      console.error(`navDialog error: ${err.code} ${err.message}`);
    }
  }
}
