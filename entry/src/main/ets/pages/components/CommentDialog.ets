import { CommentCache } from '../../model/CommentCache';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { CommentDialogParam, ImageManager } from '../../utils/ImageManager';
import { LengthMetricsUnit, MeasureUtils } from '@kit.ArkUI';

@Builder
export function CommentDialogBuilder(commentDialogParam: CommentDialogParam) {
  CommentDialog({ commentDialogParam });
}

@ComponentV2
struct CommentDialog {
  @Require @Param commentDialogParam: CommentDialogParam;
  @Local text?: string = this.commentDialogParam.cache?.getText(this.commentDialogParam.currentCommentId);
  @Local imageUri?: string = this.commentDialogParam.cache?.getImageUri(this.commentDialogParam.currentCommentId);
  private photoSelectOptions?: photoAccessHelper.PhotoSelectOptions;
  private photoPicker?: photoAccessHelper.PhotoViewPicker;
  private textAreaController: TextAreaController = new TextAreaController();

  @Local textAreaHeight: number = 72

  aboutToAppear(): void {
    this.photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    this.photoPicker = new photoAccessHelper.PhotoViewPicker();
    this.photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    this.photoSelectOptions.maxSelectNumber = 1;
  }

  @Computed
  get canPublish() {
    return this.text || this.imageUri;
  }

  @Monitor('text', 'imageUri')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      console.log(`monitor ${path} value: ${monitor.value<string>(path)?.now}, id: ${this.commentDialogParam.currentCommentId}`);
      if (path === 'text') {
        CommentCache.getInstance().setText(this.commentDialogParam.currentCommentId, monitor.value<string>(path)?.now!);
      }
      if (path === 'imageUri') {
        CommentCache.getInstance()
          .setImageUri(this.commentDialogParam.currentCommentId, monitor.value<string>(path)?.now!);
      }
    });
  }

  selectImage() {
    try {
      this.photoPicker?.select(this.photoSelectOptions)
        .then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          console.info(`PhotoViewPicker.select successfully, photoSelectResult uri: ${JSON.stringify(photoSelectResult)}`);
          if (photoSelectResult.photoUris.length) {
            this.imageUri = photoSelectResult.photoUris[0];
          }
        })
        .catch((err: BusinessError<void>) => {
          console.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
        });
    } catch (error) {
      let err: BusinessError<void> = error as BusinessError<void>;
      console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.End }) {
        this.CommentTextArea();
        this.CommentButton();
      };
      this.CommentImage();
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius({
      topLeft: 20,
      topRight: 20
    })
    .backgroundColor('#F5F5F5')
    .padding(12);
  }

  @Builder
  CommentTextArea() {
    Stack() {
      TextArea({
        placeholder: '写下你的评论',
        text: this.text!!,
        controller: this.textAreaController
      })
        .id('commentTextArea')
        .onAppear(() => {
          focusControl.requestFocus('commentTextArea');
        })
        .onChange(() => {
          const curTextHeight = this.getUIContext().px2vp(Number(this.textAreaController.getTextContentRect().height))
          const curHeight = curTextHeight + 16;
          const curLines = this.textAreaController.getTextContentLineCount();
          if (curLines === 0 || curHeight < 72) {
            this.textAreaHeight = 72;
            return
          }
          const textAreaMaxHeight = curTextHeight / curLines * 5 + 16
          console.log(`height ${curHeight} ${curLines} ${textAreaMaxHeight}`)
          if (Math.floor(curHeight) >= Math.floor(textAreaMaxHeight)) {
            this.textAreaHeight = textAreaMaxHeight;
            return
          }
          this.textAreaHeight = curHeight;
        })
        .fontWeight(1)
        .fontSize(14)
        .fontColor('#333333')
        .placeholderColor('#999999')
        .placeholderFont({
          size: 14,
          weight: 1
        })
        .minLines(1)
        // .maxLines(5)
        // .height('auto')
        .height(this.textAreaHeight)
        .barState(BarState.Off)
        .padding({
          left: 8,
          top: 8,
          bottom: 8,
          right: 40
        })
        // .constraintSize({ minHeight: 72 });
      Image($r('app.media.image'))
        .width(24)
        .height(24)
        .position({
          bottom: 8,
          right: 8
        })
        .onClick(async () => {
          if (this.imageUri) {
            this.getUIContext().getPromptAction().showToast({message: '最多只能上传1张图哦'})
            return
          }
          this.selectImage();
        });
    }
  }

  @Builder
  CommentButton() {
    Button('发送')
      .width(60)
      .height(36)
      .margin({ left: 12 })
      .padding(8)
      .fontColor(Color.White)
      .fontSize(14)
      .borderRadius(20)
      .backgroundColor(Color.Black)
      .opacity(this.canPublish ? 1 : 0.1)
      .onClick(() => {
        if (!this.canPublish) {
          return;
        }
        console.log(`send comment`);
        this.commentDialogParam.onPublish?.(this.commentDialogParam.currentCommentId);
      });
  }

  @Builder
  CommentImage() {
    if (this.imageUri) {
      Stack() {
        Image(this.imageUri)
          .width(60)
          .height(60)
          .borderRadius(8)
          .backgroundColor('#F5F5F5');
        Image($r('app.media.cancel'))
          .width(24)
          .height(24)
          .position({
            top: -10,
            right: -10
          })
          .onClick(() => {
            this.imageUri = undefined;
          });
      }
      .padding({ top: 12 })
    }
  }
}

