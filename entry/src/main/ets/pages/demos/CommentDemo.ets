import { inputMethod } from '@kit.IMEKit';
import { CommentDialogBuilder, CommentDialogParam } from '../components/CommentDialog';
import { ComponentContent, LengthMetrics } from '@ohos.arkui.node';
import { ChosenImage } from '../../utils/ImagePickerHelper';
import { promptAction } from '@kit.ArkUI';

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
        TextInput({
          placeholder: '点一下开始评论',
          controller: this.controller,
          text: this.text!!
        })
          .width('90%')
          .onClick(() => {
            this.controller.stopEditing();
            this.openDialog();
          });
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%');
    };
  }

  async openDialog() {
    const dialogContent = new ComponentContent(this.getUIContext(), wrapBuilder(CommentDialogBuilder), {
      currentCommentId: '1',
      limitOriginalFileSize: 20,
      onPublish: async (text?: string, images?: ChosenImage[]) => {
        this.text = '评论完成'
        inputMethod.getController().stopInputSession();
        await this.getUIContext().getPromptAction().closeCustomDialog(dialogContent);
        dialogContent?.dispose();
      }
    } as CommentDialogParam);
    // const dialogContent = new ComponentContent(this.getUIContext(), wrapBuilder(TestDialogBuilder));
    const options: promptAction.BaseDialogOptions = {
      alignment: DialogAlignment.Bottom,
      keyboardAvoidDistance: LengthMetrics.vp(0),
      maskTransition: TransitionEffect.OPACITY.animation({ duration: 200 }),
      dialogTransition: TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 200, curve: Curve.Ease }),
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        console.info(`close dialog onWillDismiss reason: ${dismissDialogAction.reason}`);
        inputMethod.getController().stopInputSession();
        dismissDialogAction.dismiss();
        dialogContent?.dispose();
      },
      onDidDisappear: (() => {
        console.info(`close dialog onDidDisappear`);
      }),
      onWillDisappear: (() => {
        console.info(`close dialog onWillDisappear`);
      })
    };
    try {
      await this.getUIContext().getPromptAction().openCustomDialog(dialogContent, options);
      console.info('open dialog success');
    } catch (err) {
      console.error(`open dialog error: ${err.code} ${err.message}`);
    }
  }
}