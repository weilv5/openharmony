import { CommentCache } from '../../model/CommentCache';
import { ChosenImage, ImagePickerHelper } from '../../utils/ImagePickerHelper';

export interface CommentDialogParam {
  currentCommentId: string;
  limitOriginalFileSize?: number;
  onPublish?: (text?: string, images?: ChosenImage[]) => void;
}

@Builder
export function CommentDialogBuilder(commentDialogParam: CommentDialogParam) {
  CommentDialog({
    currentCommentId: commentDialogParam.currentCommentId,
    limitOriginalFileSize: commentDialogParam.limitOriginalFileSize,
    onPublishCallback: commentDialogParam.onPublish
  });
}

@ComponentV2
struct CommentDialog {
  private readonly TEXT_AREA_PADDING: number = 8;
  private readonly TEXT_AREA_MAX_LINES: number = 5;
  private readonly TEXT_AREA_MIN_HEIGHT: number = 72 + this.TEXT_AREA_PADDING * 2;
  private readonly MAX_IMAGE_COUNT: number = 1;
  private imagePickerHelper?: ImagePickerHelper;
  private textAreaController: TextAreaController = new TextAreaController();

  @Require @Param currentCommentId: string;
  @Require @Param limitOriginalFileSize?: number;
  @Require @Param onPublishCallback: (text?: string, images?: ChosenImage[]) => void;

  @Local text?: string = CommentCache.getInstance().getText(this.currentCommentId);
  @Local selectedImage?: ChosenImage = CommentCache.getInstance().getImage(this.currentCommentId);
  @Local textAreaHeight: number = this.TEXT_AREA_MIN_HEIGHT;

  @Computed
  get sendButtonEnable() {
    return this.text || this.selectedImage;
  }

  aboutToAppear(): void {
    this.imagePickerHelper = new ImagePickerHelper(this.MAX_IMAGE_COUNT, this.limitOriginalFileSize);
  }

  private computeTextAreaHeight() {
    // 计算textarea高度，内容超过最大行数可以进行滚动
    const textHeight = this.getUIContext().px2vp(this.textAreaController.getTextContentRect().height);
    // 当前内容高度
    const curHeight = textHeight + this.TEXT_AREA_PADDING * 2;
    // 当前内容行数
    const curLines = this.textAreaController.getTextContentLineCount();
    if (curLines === 0 || curHeight < this.TEXT_AREA_MIN_HEIGHT) {
      this.textAreaHeight = this.TEXT_AREA_MIN_HEIGHT;
      return;
    }
    // 最大行数对应的高度
    const maxHeight = textHeight / curLines * this.TEXT_AREA_MAX_LINES + this.TEXT_AREA_PADDING * 2;
    if (Math.floor(curHeight) >= Math.floor(maxHeight)) {
      this.textAreaHeight = maxHeight;
      return;
    }
    this.textAreaHeight = curHeight;
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
    .borderRadius({ topLeft: 12, topRight: 12 })
    .backgroundColor(Color.White)
    .padding(16)
    .onDisAppear(() => {
      // CommentCache save
      CommentCache.getInstance().save(this.currentCommentId, this.text, this.selectedImage);
    });
  }

  @Builder
  private CommentButton() {
    Button('发送')
      .width(60 + 8 * 2)
      .height(36)
      .margin({ left: 12 })
      .padding(8)
      .fontColor(Color.White)
      .fontSize(14)
      .borderRadius(20)
      .backgroundColor(Color.Black)
      .opacity(this.sendButtonEnable ? 1 : 0.1)
      .onClick(() => {
        if (!this.sendButtonEnable) {
          return;
        }
        console.log(`send comment`);
        this.onPublishCallback(this.text?.trim(), this.selectedImage ? Array(this.selectedImage) : undefined);
      });
  }

  @Builder
  private CommentImage() {
    Stack() {
      if (this.selectedImage?.path) {
        Image(this.selectedImage?.path)
          .width(60)
          .height(60)
          .borderRadius(8)
          .backgroundColor('#F5F5F5');
        Image($r('app.media.cancel'))
          .width(24)
          .height(24)
          .position({ top: -10, right: -10 })
          .onClick(() => {
            this.selectedImage = undefined;
          });
      }
    }
    .padding({ top: 12 });
  }


  @Builder
  private CommentTextArea() {
    Stack() {
      TextArea({
        placeholder: '写下你的评论',
        text: this.text,
        controller: this.textAreaController
      })
        .id('commentTextArea')
        .onAppear(() => {
          focusControl.requestFocus('commentTextArea');
        })
        .onChange((value: string) => {
          this.text = value;
          this.computeTextAreaHeight();
        })
        .fontWeight(1)
        .fontSize(14)
        .fontColor('#333333')
        .placeholderColor('#999999')
        .placeholderFont({ size: 14, weight: 1 })
        .height(this.textAreaHeight)
        .barState(BarState.Off)
        .padding({
          left: this.TEXT_AREA_PADDING,
          top: this.TEXT_AREA_PADDING,
          bottom: this.TEXT_AREA_PADDING,
          right: this.TEXT_AREA_PADDING * 2 + 24
        });
      Image($r('app.media.image'))
        .width(24)
        .height(24)
        .position({ bottom: this.TEXT_AREA_PADDING, right: this.TEXT_AREA_PADDING })
        .onClick(async () => {
          if (!this.imagePickerHelper) {
            this.getUIContext().getPromptAction().showToast({ message: '图片选择器未初始化' });
            return;
          }
          if (this.selectedImage) {
            this.getUIContext().getPromptAction().showToast({ message: '最多只能上传1张图哦' });
            return;
          }
          await this.imagePickerHelper.openImagePicker({
            onResult: (chosenImage?: ChosenImage) => {
              this.selectedImage = chosenImage;
            },
            onError: (message: string) => {
              this.getUIContext().getPromptAction().showToast({ message: message });
            },
            onSizeLimitExceeded: (message: string) => {
              this.getUIContext().getPromptAction().showToast({ message: message });
            }
          });
        });
    };
  }
}