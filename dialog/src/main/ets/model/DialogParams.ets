import { BaseModel } from '@my/base';

export class BindSheetParams extends BaseModel {
  title: string = '';
  text: string = '';
  callback?: (code: number) => void;

  static newInstance(): BindSheetParams {
    return new BindSheetParams();
  }

  toJson(): string {
    throw new Error('Method not implemented.');
  }
}

export class CustomDialogParams extends BaseModel {
  text: string = '';

  static newInstance(): CustomDialogParams {
    return new CustomDialogParams();
  }

  toJson(): string {
    throw new Error('Method not implemented.');
  }
}

export class OverlayManagerParams extends BaseModel {
  text: string = '';
  close: () => void = () => {
  };

  static newInstance(): OverlayManagerParams {
    return new OverlayManagerParams();
  }

  toJson(): string {
    throw new Error('Method not implemented.');
  }
}

export class NavDialogParams extends BaseModel {
  text: string = '';
  close: () => void = () => {
  };

  static newInstance(): NavDialogParams {
    return new NavDialogParams();
  }

  toJson(): string {
    throw new Error('Method not implemented.');
  }
}
