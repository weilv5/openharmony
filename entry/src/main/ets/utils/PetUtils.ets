import { Want, common } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { DialogUtils } from '@my/dialog';
import { ComponentContent, LengthMetrics } from '@kit.ArkUI';
import { BindSheetParams } from '@my/dialog/src/main/ets/model/DialogParams';
import { Dialog } from '@my/dialog/src/main/ets/components/DialogComponents';
import { PetDialogBuilder } from '../pages/components/PatDialog';

export class PetUtils {
  private static context?: common.UIAbilityContext;

  static async init(context: common.UIAbilityContext) {
    PetUtils.context = context;
  }

  static async handle(want: Want): Promise<void> {
    try {
      const sharedData: systemShare.SharedData = await systemShare.getSharedData(want);
      const records = sharedData.getRecords();
      for (let i = 0; i < records.length; i++) {
        const uri = records[i].uri;
        if (uri) {
          console.log(`PetUtils.handle ${uri}`)
          PetUtils.openDialog(uri)
          continue;
        }
      }
    } catch (error) {
    }
  }

  private static async openDialog(uri:string) {
    const uiContext = AppStorage.get('UIContext') as UIContext;
    const bindSheetContent: ComponentContent<string> =
      new ComponentContent(uiContext, wrapBuilder(PetDialogBuilder), uri);
    const sheetOptions: SheetOptions = {
      height: SheetSize.FIT_CONTENT,
      preferType: SheetType.BOTTOM,
      showClose: false,
      radius: LengthMetrics.vp(12),
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
}