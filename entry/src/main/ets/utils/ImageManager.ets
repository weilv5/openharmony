import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { util } from '@kit.ArkTS';
import { CommentCache } from '../model/CommentCache';

export interface ImageInfo {
  type?: string;
  path?: string;
  size?: number;
  mime?: string;
  base64?: string;
  filename?: string;
  width?: number;
  height?: number;
}

export interface ChosenImage {
  path?: string;
  size?: number;
  mime?: string;
  base64?: string;
  filename?: string;
  width?: number;
  height?: number;
}

export interface CommentDialogParam {
  currentCommentId: string;
  cache?: CommentCache;
  onPublish?: (commentId: string) => void;
}

export class ImageManager {
  private static instance: ImageManager;
  private photoSelectOptions: photoAccessHelper.PhotoSelectOptions;
  private photoPicker: photoAccessHelper.PhotoViewPicker;
  private base64Helper: util.Base64Helper;

  private constructor() {
    this.photoPicker = new photoAccessHelper.PhotoViewPicker();
    this.photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    this.photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    this.photoSelectOptions.maxSelectNumber = 1;

    this.base64Helper = new util.Base64Helper();
  }

  static getInstance() {
    if (!ImageManager.instance) {
      ImageManager.instance = new ImageManager();
    }
    return ImageManager.instance;
  }

  async select(): Promise<Optional<string>> {
    try {
      const photoSelectResult: photoAccessHelper.PhotoSelectResult =
        await this.photoPicker.select(this.photoSelectOptions);
      const photoUri = photoSelectResult.photoUris[0];
      return photoUri;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
      return;
    }
  }

  imageInfo(imageUri?: string): Optional<ChosenImage> {
    if (!imageUri) {
      return;
    }
    let file: fs.File | null = null;
    try {
      const chosenImage: ChosenImage = {};

      const stat = fs.statSync(imageUri);
      chosenImage.size = stat.size;

      file = fs.openSync(imageUri, fs.OpenMode.READ_ONLY);
      chosenImage.path = imageUri;
      chosenImage.filename = `${file.getParent()}/${file.name}`;

      const buf = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buf);
      const imageBase64Str = this.base64Helper.encodeToStringSync(new Uint8Array(buf), util.Type.BASIC);

      chosenImage.base64 = imageBase64Str;

      const imageSourceApi = image.createImageSource(file.fd);

      const imageInfo = imageSourceApi.getImageInfoSync();
      chosenImage.width = imageInfo.size.width;
      chosenImage.height = imageInfo.size.height;
      chosenImage.mime = imageInfo.mimeType;

      imageSourceApi.release();
      return chosenImage;
    } catch (e) {
      let err: BusinessError = e as BusinessError;
      console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
      return;
    } finally {
      // 释放资源
      if (file !== null) {
        fs.closeSync(file.fd);
      }
    }
  }
}
