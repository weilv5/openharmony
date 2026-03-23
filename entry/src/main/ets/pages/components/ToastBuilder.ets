export interface ToastParam {
  /**
   * 消息内容
   */
  message: ResourceStr;
  /**
   * 类型：信息、成功、错误、加载中、纯文本
   */
  type?: number;
  /**
   * 显示时长(毫秒)
   */
  duration?: number;
  /**
   * 是否可取消
   */
  cancelable?: boolean;
  /**
   * 图标资源
   */
  icon?: Resource;
  /**
   * 是否暗黑模式
   */
  isDarkMode?: boolean;
  /**
   * 宽度
   */
  width?: Dimension;
  /**
   * 高度
   */
  height?: Dimension;
  iconBorderRadius?: Dimension;
  /**
   * 圆角半径
   */
  borderRadius?: number;
  /**
   * 边框颜色
   */
  borderColor?: ResourceColor;
  /**
   * 边框宽度
   */
  borderWidth?: number;
  /**
   * 背景颜色
   */
  backgroundColor?: ResourceColor;
  /**
   * 文字大小
   */
  textSize?: number;
  /**
   * 文字颜色
   */
  textColor?: ResourceColor;
  /**
   * 图标宽度
   */
  iconWidth?: number;
  /**
   * 图标高度
   */
  iconHeight?: number;
  /**
   * 字体家族
   */
  fontFamily?: string;
  /**
   * 字重
   */
  fontWeight?: number | string;
  /**
   * 行高
   */
  lineSpacing?: number;
  /**
   * 文本对齐方式
   */
  textAlign?: TextAlign;
  /**
   * 垂直内边距
   */
  verticalPadding?: number;
  /**
   * 水平内边距
   */
  horizontalPadding?: number;
  /**
   * 阴影效果
   */
  shadow?: ShadowOptions | ShadowStyle;
  /**
   * 位置：顶部、居中、底部
   */
  position?: 'top' | 'center' | 'bottom';
  /**
   * 重复显示参数
   */
  repeatable?: boolean;
  /**
   * 触发返回
   */
  onBackPressed?: () => void;
}
@Builder
function toastContentBuilder(params: ToastParam) {
  // 使用Row布局使图标和文本水平排列
  Row() {
    Image($r('app.media.micar_icon'))
      .width(params.iconWidth || 26)
      .height(params.iconHeight || 26)
      .margin({ right: 8 })
      .borderRadius(params.iconBorderRadius ?? 0)
    // 文本内容和按钮放在一个Column中
    Column() {
      // 文本内容
      // 当类型为TEXT时，文字对齐方式强制为居中对齐
      Text(params.message)
        .fontSize(params.textSize || 14)
        .fontColor(params.textColor || (params.isDarkMode ? '#80FFFFFF' : '#99000000'))
        .textAlign(TextAlign.Center)
        .fontFamily(params.fontFamily || 'MiSans')
        .fontWeight(params.fontWeight || 330)
        .lineHeight(params.lineSpacing ? (params.textSize || 15) + params.lineSpacing : undefined)
    }
    .constraintSize({
      maxWidth: 218
    })
    .alignItems(HorizontalAlign.Center)
  }
  .alignItems(VerticalAlign.Center) // 垂直居中
}

@Builder
export function ToastBaseBuilder(params: ToastParam) {
  // 默认底部对齐
  Column() {
    toastContentBuilder(params)
  }
  .focusable(false)
  .width(params.width || 'auto')
  .height(params.height || 'auto')
  .padding({
    top: params.verticalPadding ?? 15.5,
    bottom: params.verticalPadding ?? 15.5,
    left: params.horizontalPadding ?? 20,
    right: params.horizontalPadding ?? 20
  })
  .shadow(params.shadow || ShadowStyle.OUTER_DEFAULT_MD)
  .borderRadius(params.borderRadius ?? 16)
  .border({
    width: params.borderWidth ?? 0.34,
    color: params.borderColor || (params.isDarkMode ? '#1AFFFFFF' : '#1A000000')
  })
  .backgroundColor(params.backgroundColor || (params.isDarkMode ? '#1C1C1F' : '#FAFAFA'))
}