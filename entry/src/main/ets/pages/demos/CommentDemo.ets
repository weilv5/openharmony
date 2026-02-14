import { CommentDialogBuilder } from '../components/CommentDialog';
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { CommentCache } from '../../model/CommentCache';
import { LengthMetrics } from '@ohos.arkui.node';
import { CommentDialogParam } from '../../utils/ImageManager';

@Builder
export function CommentPageBuilder() {
  CommentPage();
}

@ComponentV2
struct CommentPage {
  @Local text: string = '';
  num: number = 4;
  lineHeight: number = 20;
  @Local areaHeight: number = 80;
  lineSpacing: number = 10;
  controller: TextAreaController = new TextAreaController();

  aboutToAppear(): void {
    this.areaHeight = this.lineHeight * this.num + (this.num - 1) * this.lineSpacing;
  }

  build() {
    NavDestination() {
      Column() {
        TextArea({
          text: this.text,
          placeholder: 'placeholder',
          // controller: this.controller
        })
          .placeholderFont({ size: 16, weight: 400 })
          .width('90%')
          .height(this.areaHeight)
          // .lineHeight(this.lineHeight)
          .fontSize(14)
          // .lineSpacing(LengthMetrics.px(this.lineSpacing))
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_list_card'))
        // TextInput({
        //   placeholder: '点一下开始评论'
        // })
        Button('点一下开始评论')
          .width('90%')
          .onClick(() => {
            this.openDialog();
          });
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%');
    };
  }

  async openDialog() {
    const bindSheetContent = new ComponentContent(this.getUIContext(), wrapBuilder(CommentDialogBuilder), {
      currentCommentId: '1',
      cache: CommentCache.getInstance(),
      onPublish: (commentId: string) => {
        CommentCache.getInstance().clear();
        bindSheetContent.dispose();
      }
    } as CommentDialogParam);
    const options: promptAction.BaseDialogOptions = {
      alignment: DialogAlignment.Bottom,
      keyboardAvoidDistance: LengthMetrics.vp(0),
      maskTransition: TransitionEffect.OPACITY.animation({ duration: 200 }),
      dialogTransition: TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 200 }),
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        // 半模态页面的交互式关闭回调函数。允许开发者注册，以获取关闭操作的类型，并决定是否关闭半模态状态
        console.info(`bindSheet closed reason: ${dismissDialogAction.reason}`);
        dismissDialogAction.dismiss();
      },
    };
    try {
      await this.getUIContext().getPromptAction().openCustomDialog(bindSheetContent, options);
      console.info('openBindSheet success');
    } catch (err) {
      console.error(`openBindSheet error: ${err.code} ${err.message}`);
    }
  }
}