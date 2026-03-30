import { PAGFile, PAGViewController, PAGViewV2 } from '@tencent/libpag';
import { PAGScaleMode } from '@tencent/libpag/src/main/ets/PAGScaleMode';

enum PetDialogType {
  SELECT, SELECT_FAIL, CREATING, VIEW, VIEW_LOADING, SEND_SUCCESS, SEND_FAIL, NO_WIFI
}

interface IPetImageInfo {
  text?: string,
  time?: string,
  icon?: ResourceStr
}

interface IPetInfo {
  title: string,
  buttons: string[],
  icon?: Resource,
  failText?: string,
  views?: string[],
  isLoading?: boolean,
  createdImages?: string[],
  imageInfo?: IPetImageInfo
}

function petInfo(type: PetDialogType, uri: string): IPetInfo {
  switch (type) {
    case PetDialogType.SELECT:
      return {
        title: '生成 AI 萌宠',
        buttons: ['取消', '确认生成']
      };
    case PetDialogType.CREATING:
      return {
        title: 'AI 萌宠照片生成中',
        buttons: ['隐藏']
      };
    case PetDialogType.SELECT_FAIL:
      return {
        title: 'AI 萌宠照片生成失败',
        buttons: ['知道了'],
        icon: $r('app.media.pet_dialog_fail'),
        failText: '图片不符合平台规范，请更换后再试'
      };
    case PetDialogType.VIEW:
      return {
        title: '选择你的 AI 萌宠照片',
        buttons: ['重新生成', '发送到车'],
        createdImages: [uri, uri, uri],
        imageInfo: { time: '2026.3.10' }
      };
    case PetDialogType.VIEW_LOADING:
      return {
        title: 'AI 萌宠照片预览',
        buttons: ['重新生成', '发送到车'],
        createdImages: [uri],
        imageInfo: { text: 'AI 萌宠照片已生成', time: '2027.3.11' }
      };
    case PetDialogType.SEND_SUCCESS:
      return {
        title: '发送成功',
        buttons: ['确定'],
        createdImages: [uri],
        imageInfo: { text: '请在车机「玩具箱」查看', icon: $r('app.media.pet_success') }
      };
    case PetDialogType.SEND_FAIL:
      return {
        title: '发送失败',
        buttons: ['重新发送'],
        icon: $r('app.media.pet_dialog_fail'),
        failText: '萌宠照片发送失败'
      };
    case PetDialogType.NO_WIFI:
      return {
        title: '发送失败',
        buttons: ['取消', '重新发送'],
        icon: $r('app.media.pet_create_no_net'),
        failText: '无网络连接，请检查后重试'
      };
  }
}

@Builder
export function PetDialogBuilder(uri: string) {
  PetDialog({ uri: uri });
}

@ComponentV2
struct PetDialog {
  _index: number = 0;
  @Require @Param uri: string;
  @Local type: PetDialogType = PetDialogType.SELECT;
  private indicatorController: IndicatorComponentController = new IndicatorComponentController();

  @Computed
  get petDialogInfo(): IPetInfo {
    const info = petInfo(this.type, this.uri);
    if (this.type === PetDialogType.VIEW_LOADING) {
      setTimeout(() => {
        info.isLoading = false;
      }, 5000);
    }
    return info;
  }

  changeType() {
    console.log(`changeType ${this._index}`);
    this._index++;
    this.type = this._index % 8;
  }

  build() {
    Column() {
      PetDialogTitle({
        title: this.petDialogInfo.title,
        subTitle: '本月剩余 3 次',
        onClosed: () => {
          this.changeType();
        }
      });
      this.PetViewArea();
      PetDialogButton({
        cancelText: this.petDialogInfo.buttons[0],
        confirmText: this.petDialogInfo.buttons[1],
      });
    }
    .backgroundImage(this.type === PetDialogType.VIEW ? $r('app.media.pet_loading_bg') : undefined)
    .backgroundImageSize({ width: '100%', height: '100%'})
    .width('100%')
    .backgroundColor('#242424');
  }

  @Builder
  PetViewArea() {
    if (this.type === PetDialogType.SELECT) {
      PetImageShare({
        uri: this.uri
      });
    }
    if (this.type === PetDialogType.SELECT_FAIL) {
      PetMessageView({
        text: this.petDialogInfo.failText,
        icon: this.petDialogInfo.icon
      });
    }
    if (this.type === PetDialogType.CREATING) {
      PetCreatingView();
    }
    if (this.type === PetDialogType.VIEW) {
      PetImageView({
        images: this.petDialogInfo.createdImages,
        imageInfo: this.petDialogInfo.imageInfo,
        indicatorController: this.indicatorController,
        onDisplayChange: (index: number) => {
          // this.currentIndex = index;
        },
        onSelectChange: (index: number) => {
          // this.selectedIndex = index;
        }
      });
    }
    if (this.type === PetDialogType.VIEW_LOADING) {
      PetImageView({
        images: this.petDialogInfo.createdImages,
        imageInfo: this.petDialogInfo.imageInfo,
        indicatorController: this.indicatorController
      });
    }
    if (this.type === PetDialogType.SEND_SUCCESS) {
      PetImageView({
        images: this.petDialogInfo.createdImages,
        imageInfo: this.petDialogInfo.imageInfo,
        indicatorController: this.indicatorController
      });
    }
    if (this.type === PetDialogType.SEND_FAIL) {
      PetMessageView({
        text: this.petDialogInfo.failText,
        icon: this.petDialogInfo.icon
      });
    }
    if (this.type === PetDialogType.NO_WIFI) {
      PetMessageView({
        text: this.petDialogInfo.failText,
        icon: this.petDialogInfo.icon
      });
    }
  }
}

// 图片分享
@ComponentV2
struct PetImageShare {
  @Require @Param uri: string;

  build() {
    Column() {
      Image(this.uri)
        .width(265)
        .height(265)
        .borderRadius(4);
    }
    .justifyContent(FlexAlign.Center)
    .height(376)
    .margin({ top: 16, bottom: 16 });
  }
}

@ComponentV2
struct PetImageInfo {
  @Param @Require text: string;
  @Param timeStr?: string = undefined;
  @Param icon?: ResourceStr = undefined;

  build() {
    Column() {
      Row() {
        if (this.icon) {
          Image(this.icon)
            .width(20)
            .height(20)
            .margin({ right: 8 });
        }
        Text(this.text)
          .fontColor('#e6ffffff')
          .fontSize(16)
          .fontWeight(430);
      };

      if (this.timeStr) {
        PetTime() {
          Text(this.timeStr)
            .fontColor('#66ffffff')
            .fontSize(9)
            .fontWeight(400);
        };
      }
    }
    .justifyContent(FlexAlign.Center)
    .height(64);
  }
}

@ComponentV2
struct PetViewBg {
  @BuilderParam content: () => void;

  build() {
    Column() {
      Stack() {
        // 展示背景
        Column() {
          // 展示内容
          Column() {
          }
          .width(248)
          .height(312)
          .borderRadius(14)
          .borderWidth(1)
          // .padding({ top: 4, right: 4, left: 4 })
          .borderColor('#000000');
        }
        .width(256)
        .height(320)
        .borderRadius(18)
        .backgroundImage($r('app.media.pet_create_background'))
        .backgroundImageSize({ width: 256, height: 320 })
        .justifyContent(FlexAlign.Center);

        this.content();

        Column() {
          Image($r('app.media.pet_view_shadow'))
            .width(310)
            .height(44);
        }
        .width('100%')
        .position({ bottom: -4 });

      };
    }
    .justifyContent(FlexAlign.Center)
    .width('100%');
  }
}

@ComponentV2
struct PetTime {
  @BuilderParam content: () => void;

  build() {
    Row({ space: 8 }) {
      Image($r('app.media.pet_line'))
        .width(6)
        .height(1);
      this.content();
      Image($r('app.media.pet_line'))
        .width(6)
        .height(1);
    }
    .margin({ top: 6 });
  }
}

@ComponentV2
struct PetAIImage {
  @Require @Param uri: ResourceStr;
  @Local isLoading: boolean = true;

  build() {
    Stack() {
      this.PetImageLoading();
      this.PetImage();
    };
  }

  @Builder
  PetImageLoading() {
    Stack() {
      // Image($r('app.media.pet_loading_bg'))
      //   .width(240)
      //   .height(240)
      //   .borderRadius(10)
      //   .backgroundColor('#242424');
      // .margin({ top: 4, right: 4, left: 4 });
      LoadingProgress()
        .width(24)
        .height(24)
        .color(Color.White);
    }
    .width(240)
    .height(240)
    .visibility(this.isLoading ? Visibility.Visible : Visibility.None);
  }

  @Builder
  PetImage() {
    RelativeContainer() {
      Image(this.uri)
        .width(240)
        .height(240)
        .borderRadius(10)
        .onComplete(() => {
          setTimeout(() => {
            this.isLoading = false;
          }, 5000);
        })
        .id('aiImage');
      Row() {
        Text('AI生成')
          .fontColor(Color.White)
          .fontSize(10)
          .fontWeight(500);
      }
      .width(38)
      .height(18)
      .borderRadius(4)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1a000000')
      .alignRules({
        right: { anchor: 'aiImage', align: HorizontalAlign.End },
        bottom: { anchor: 'aiImage', align: VerticalAlign.Bottom },
      })
      .offset({ x: -8, y: -8 });
    }
    .width(240)
    .height(240)
    .visibility(this.isLoading ? Visibility.Hidden : Visibility.Visible);
  }
}

@ComponentV2
struct PetImageSwiper {
  // 轮播整体可视区域宽度。
  private static readonly SWIPER_WIDTH: number = 654;
  // 轮播整体可视区域高度。
  private static readonly SWIPER_HEIGHT: number = 240;
  // 左右两侧露出区域边距。
  private static readonly SWIPER_SIDE_MARGIN: number = 192;
  // 卡片与卡片之间的间距。
  private static readonly SWIPER_ITEM_SPACE: number = 15;
  // Swiper 自身切页动画时长。
  private static readonly SWIPER_ANIMATION_DURATION: number = 200;
  // 选中卡片的最大缩放值。
  private static readonly MAX_SCALE: number = 1;
  // 未选中卡片的最小缩放值。
  private static readonly MIN_SCALE: number = 0.8;
  // 选中卡片的最大透明度。
  private static readonly MAX_OPACITY: number = 1;
  // 未选中卡片的最小透明度。
  private static readonly MIN_OPACITY: number = 0.4;
  // 中心附近的缓冲区，避免松手进入自动收敛时 scale/opacity 立刻明显跳变。
  private static readonly CENTER_DEAD_ZONE: number = 0.08;

  @Param @Require indicatorController: IndicatorComponentController;
  @Param @Require images: ResourceStr[];
  // 展示索引变化回调，用于页码、说明文案等 UI 展示。
  @Param onDisplayChange?: (index: number) => void = undefined;
  // 业务选中索引变化回调，用于最终选图提交。
  @Param onSelectChange?: (index: number) => void = undefined;
  // Swiper 最终落位后的真实索引。
  @Local swiperIndex: number = 0;
  // 提前用于展示的索引，会在动画开始时更新。
  @Local displayIndex: number = 0;
  // 每一张图当前的缩放值列表，由自定义转场实时驱动。
  @Local scaleList: number[] = [];
  // 每一张图当前的透明度列表，由自定义转场实时驱动。
  @Local opacityList: number[] = [];

  aboutToAppear(): void {
    // 首次出现时，先按当前 swiperIndex 初始化每一张图的默认视觉状态。
    this.ensureTransitionState();
  }

  @Monitor('images')
  onImagesChange(): void {
    // 图片列表变化时，重新按当前 swiperIndex 初始化视觉状态，避免数组长度不一致。
    this.ensureTransitionState();
  }

  private ensureTransitionState(): void {
    // 重新构造缩放列表，确保每张图都有默认值。
    const scaleList: number[] = [];
    // 重新构造透明度列表，确保每张图都有默认值。
    const opacityList: number[] = [];
    // 遍历全部图片，按“当前页/非当前页”生成基础视觉状态。
    for (let i = 0; i < this.images.length; i++) {
      // 当前选中页为最大缩放，其余页为缩小态。
      scaleList.push(i === this.swiperIndex ? PetImageSwiper.MAX_SCALE : PetImageSwiper.MIN_SCALE);
      // 当前选中页为最大透明度，其余页为半透明态。
      opacityList.push(i === this.swiperIndex ? PetImageSwiper.MAX_OPACITY : PetImageSwiper.MIN_OPACITY);
    }
    // 一次性替换缩放数组，触发界面刷新。
    this.scaleList = scaleList;
    // 一次性替换透明度数组，触发界面刷新。
    this.opacityList = opacityList;
  }

  /**
   * 计算平滑后的距离系数。
   *
   * 目的：
   * - 保留最终的 1 -> 0.8、1 -> 0.4 视觉目标
   * - 但让中心附近的变化更钝一些，减轻手离开屏幕后进入自动收敛时的闪动感
   *
   * @param position 当前 item 相对中心的位置。
   * @returns 0~1 的平滑距离系数。
   */
  private resolveSmoothDistance(position: number): number {
    const rawDistance = Math.min(1, Math.abs(position));
    if (rawDistance <= PetImageSwiper.CENTER_DEAD_ZONE) {
      return 0;
    }
    const normalizedDistance =
      (rawDistance - PetImageSwiper.CENTER_DEAD_ZONE) / (1 - PetImageSwiper.CENTER_DEAD_ZONE);
    // smoothstep：在 0 和 1 两端都更平滑，减少松手时的突兀变化。
    return normalizedDistance * normalizedDistance * (3 - 2 * normalizedDistance);
  }

  /**
   * 监听轮播下标变化并向外同步。
   *
   * @param monitor ArkUI 监听器。
   * @returns 无返回值。
   */
  @Monitor('displayIndex')
  onDisplayIndexChange(monitor: IMonitor) {
    // 从监视器中读取 displayIndex 的新旧值。
    const change = monitor.value<number>('displayIndex');
    if (change) {
      // 把展示索引回传给外层，用于页码、说明文案等 UI 提前更新。
      this.onDisplayChange?.(change.now);
    }
  }

  build() {
    Swiper() {
      ForEach(this.images, (item: string, index: number) => {
        PetAIImage({ uri: item })
          .scale({
            x: this.scaleList[index] ?? PetImageSwiper.MIN_SCALE,
            y: this.scaleList[index] ?? PetImageSwiper.MIN_SCALE
          })
          .opacity(this.opacityList[index] ?? PetImageSwiper.MIN_OPACITY)
          // .animation({
          //   duration: 400,
          //   curve: Curve.Linear
          // });
      });
    }
    // 设置轮播整体宽度。
    .width(PetImageSwiper.SWIPER_WIDTH)
    // 设置轮播整体高度。
    .height(PetImageSwiper.SWIPER_HEIGHT)
    // 预缓存前后页，降低切页时的资源抖动。
    .cachedCount(2)
    // 每次只选中展示一页，左右通过 margin 露出侧边内容。
    .displayCount(1)
    // 使用受控索引，保证轮播最终停留页和本地状态一致。
    .index(this.swiperIndex)
    // 不自动轮播。
    .autoPlay(false)
    // 不循环。
    .loop(false)
    // 设置 Swiper 自身的切页动画时长。
    .duration(PetImageSwiper.SWIPER_ANIMATION_DURATION)
    // 不允许点击指示器直接切页。
    .indicatorInteractive(false)
    // 设置卡片之间的间距。
    .itemSpace(PetImageSwiper.SWIPER_ITEM_SPACE)
    // 设置前一页露出的边距。
    .prevMargin(PetImageSwiper.SWIPER_SIDE_MARGIN)
    // 设置后一页露出的边距。
    .nextMargin(PetImageSwiper.SWIPER_SIDE_MARGIN)
    // 挂载外部指示器控制器。
    .indicator(this.indicatorController)
    // 自定义内容转场，在滑动过程中实时计算每张图的缩放和透明度。
    .customContentTransition({
      transition: (proxy: SwiperContentTransitionProxy) => {
        // 当前位置离中心越远，distance 越接近 1。
        // 这里先做一层中心缓冲和平滑处理，降低松手瞬间的视觉跳变。
        const distance = this.resolveSmoothDistance(proxy.position);
        // 根据平滑后的距离系数，插值计算缩放值。
        this.scaleList[proxy.index] = PetImageSwiper.MAX_SCALE -
          (PetImageSwiper.MAX_SCALE - PetImageSwiper.MIN_SCALE) * distance;
        // 透明度和缩放共用同一套平滑距离，避免两套视觉节奏不一致。
        this.opacityList[proxy.index] = PetImageSwiper.MAX_OPACITY -
          (PetImageSwiper.MAX_OPACITY - PetImageSwiper.MIN_OPACITY) * distance;
      }
    })
    // 动画开始时，先把展示索引切到目标页，让页码和说明文案提前变化。
    .onAnimationStart((_index: number, targetIndex: number) => {
      this.displayIndex = targetIndex;
    })
    // 动画最终落位后，再同步真实选中页。
    .onChange((targetIndex: number) => {
      // 更新 Swiper 最终停留页索引。
      this.swiperIndex = targetIndex;
      // 让展示索引也和最终停留页保持一致。
      this.displayIndex = targetIndex;
      // 把最终选中页回传给外层，用于发送到车等业务提交。
      this.onSelectChange?.(targetIndex);
    });
  }
}

@ComponentV2
struct PetDialogTitle {
  @Param title: string = '';
  @Param subTitle: string = '';
  @Param onClosed?: () => void = undefined;

  build() {
    Row() {
      Column({ space: 14 }) {
        Text(this.title)
          .fontColor('#E6FFFFFF')
          .fontSize(18)
          .fontWeight(430);
        Text(this.subTitle)
          .fontSize(13)
          .fontColor(Color.Orange)
      }
      .padding({ left: 40, right: 40 });

      Image($r('app.media.pet_dialog_close'))
        .width(40)
        .height(40)
        .colorFilter('#E6FFFFFF')
        .position({
          top: '50%',
          right: -12
        })
        .markAnchor({ y: 20 })
        .onClick(() => {
          this.onClosed?.();
        });
    }
    .width('100%')
    .height(64)
    .padding({
      top: 28,
      right: 28,
      bottom: 16,
      left: 28
    })
    .justifyContent(FlexAlign.Center);
  }
}

@ComponentV2
struct PetDialogButton {
  @Param cancelText?: string = undefined;
  @Param confirmText?: string = undefined;
  @Param onCancel?: () => void = undefined;
  @Param onConfirm?: () => void = undefined;

  build() {
    Row({ space: 12 }) {
      if (this.cancelText) {
        Button(this.cancelText)
          .layoutWeight(1)
          .fontColor('#b3ffffff')
          .backgroundColor('#26ffffff')
          .padding({ left: 20, right: 20 })
          .borderRadius(4)
          .width('100%')
          .height(50)
          // .margin({ left: 6, right: 6 })
          .onClick(() => {
            this.onCancel?.();
          });
      }
      if (this.confirmText) {
        Button(this.confirmText)
          .layoutWeight(1)
          .fontColor('#e6ffffff')
          .backgroundColor('#007CFF')
          .padding({ left: 20, right: 20 })
          .borderRadius(4)
          .width('100%')
          .height(50)
          // .margin({ left: 6, right: 6 })
          .onClick(() => {
            this.onConfirm?.();
          });
      }
    }
    .width('100%')
    .padding({
      top: 8,
      right: 28,
      bottom: 28,
      left: 28
    })
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

// 图片分析/创建萌宠/发送到车错误信息
@ComponentV2
struct PetMessageView {
  @Param text: string = '';
  @Param icon?: ResourceStr = undefined;

  build() {
    Column() {
      if (this.icon) {
        Image(this.icon)
          .colorFilter(Color.Blue)
          .width(60)
          .height(60);
      }

      Text(this.text)
        .fontSize(16)
        .fontWeight(500)
        .fontColor('#ccffffff')
        .margin(16);
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(384)
    // .padding({ left: 56, right: 56 })
    .margin({ top: 8, bottom: 16 });
  }
}

@ComponentV2
struct PetImageView {
  @Require @Param images: ResourceStr[];
  @Require @Param imageInfo?: IPetImageInfo;
  @Param @Require indicatorController: IndicatorComponentController;
  @Param onDisplayChange?: (index: number) => void = undefined;
  @Param onSelectChange?: (index: number) => void = undefined;
  @Local swiperIndex: number = 0;

  @Computed
  get isSwiper() {
    return this.images && this.images.length > 1;
  }

  build() {
    Column() {
      PetViewBg() {
        Column() {
          if (this.isSwiper) {
            PetImageSwiper({
              indicatorController: this.indicatorController,
              images: this.images,
              onDisplayChange: (index: number) => {
                this.swiperIndex = index;
                this.onDisplayChange?.(index);
              },
              onSelectChange: (index: number) => {
                this.onSelectChange?.(index);
              }
            });
            PetImageInfo({
              text: `第 ${this.swiperIndex + 1} 张`,
              timeStr: this.imageInfo?.time,
              icon: this.imageInfo?.icon
            })
              .offset({ y: 2 });
            Column() {
              this.PetImageSwiperIndicator();
            }
            .width('100%')
            .position({ bottom: 6 });
          } else {
            PetAIImage({
              uri: this.images[0]
            });
            // .margin({ top: 4, right: 4, left: 4 });
            PetImageInfo({
              text: this.imageInfo?.text,
              timeStr: this.imageInfo?.time,
              icon: this.imageInfo?.icon
            })
              .offset({ y: 2 });
          }
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%');
      };
    }
    .justifyContent(FlexAlign.Center)
    .height(400)
    .margin({ top: 8 });
  }

  @Builder
  PetImageSwiperIndicator() {
    IndicatorComponent(this.indicatorController)
      .style(// 设置圆点导航点样式
        new DotIndicator()
          .itemWidth(4)
          .itemHeight(4)
          .selectedItemWidth(12)
          .selectedItemHeight(4)
          .color('#66ffffff')
          .selectedColor('#ffffff')
          .bottom(200));
  }
}

@ComponentV2
struct PetCreatingView {
  private readonly pagController: PAGViewController = new PAGViewController();
  @Local usePag: boolean = true;

  aboutToAppear(): void {
    this.loadPagFile();
  }

  private async loadPagFile(): Promise<void> {
    try {
      const fileBuffer =
        await this.getUIContext().getHostContext()?.resourceManager.getMediaContent($r('app.media.pet_card').id);
      const pagFile = PAGFile.LoadFromBytes(fileBuffer?.buffer, 'pet_card.pag');
      if (!pagFile) {
        this.usePag = false;
        return;
      }

      this.pagController.setComposition(pagFile);
      this.pagController.setScaleMode(PAGScaleMode.LetterBox);
      this.pagController.setRepeatCount(0);
      this.pagController.setSync(false);
      this.pagController.setCacheEnabled(true);
      this.pagController.setUseDiskCache(true);
      this.pagController.setMaxFrameRate(60);
      this.pagController.setProgress(0);
      this.pagController.flush();

      this.pagController.play();
    } catch (error) {
      this.usePag = false;
    }
  }

  build() {
    Column() {
      if (this.usePag) {
        Stack() {
          Stack() {
            PAGViewV2({ controller: this.pagController })
              .width(256)
              .height(320);
            Text('预计 1~2 分钟')
              .fontColor('#80ffffff')
              .fontWeight(400)
              .fontSize(14)
              .offset({ top: 13 })
          }

          Column() {
            Image($r('app.media.pet_view_shadow'))
              .width(310)
              .height(44);
          }
          .width('100%')
          .position({ bottom: -44 });
        }
      } else {
        PetViewBg() {
          Column() {
            Image($r('app.media.pet_create_wait'))
              .width(40)
              .height(40);
            Text('预计 1~2 分钟')
              .fontColor('#80ffffff')
              .fontSize(14)
              .fontWeight(330)
              .margin({ top: 8 });
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%');
        };
      }
    }
    .justifyContent(FlexAlign.Center)
    .height(400)
    .margin({ top: 8 });
  }
}
