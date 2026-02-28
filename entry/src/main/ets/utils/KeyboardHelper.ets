import { inputMethod } from '@kit.IMEKit';

const TAG = 'KeyboardHelper';

export class KeyboardHelper {

  static hideKeyboard() {
    inputMethod.getController().stopInputSession();
  }
}