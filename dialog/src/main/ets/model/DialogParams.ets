import { BaseModel } from '@my/base';
import { DialogType } from './DialogType';

interface IDialogParams {
  title?: string;
  content?: string;
  confirm?: () => void;
  cancel?: () => void;
}

export abstract class DialogParams extends BaseModel {
  readonly title?: string;
  readonly content?: string;
  readonly confirm?: () => void;
  readonly cancel?: () => void;
  type?: DialogType;

  constructor(params: IDialogParams) {
    super();
    this.title = params.title;
    this.content = params.content;
    this.confirm = params.confirm;
    this.cancel = params.cancel;
  }

  toJson(): string {
    return `The dialog title=${this.title} content=${this.content}`;
  }
}

export class BindSheetParams extends DialogParams {
  constructor(params: IDialogParams) {
    super(params);
    this.type = DialogType.BIND_SHEET;
  }
}

export class CustomDialogParams extends DialogParams {
  constructor(params: IDialogParams) {
    super(params);
    this.type = DialogType.CUSTOM;
  }
}

export class OverlayManagerParams extends DialogParams {
  useBackground: boolean;

  constructor(params: IDialogParams) {
    super(params);
    this.type = DialogType.OVERLAY;
    this.useBackground = true;
  }
}

export class NavDialogParams extends DialogParams {
  useBackground: boolean;

  constructor(params: IDialogParams) {
    super(params);
    this.type = DialogType.NAV;
    this.useBackground = true;
  }
}
