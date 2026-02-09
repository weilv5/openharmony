@ComponentV2
export struct FullColumn {

  @BuilderParam content: () => void;

  build() {
    Column({ space: 10 }) {
      this.content()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center);
  }

}