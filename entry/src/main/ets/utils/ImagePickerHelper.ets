import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { CompressParams, ImageProcessor, ImageProcessorError, ValidationErrorType } from './ImageProcessor';

const TAG = 'ImagePickerHelper';

export class ImagePickerHelper {
  private limitOriginalFileSize: Optional<number>;
  private photoPicker: photoAccessHelper.PhotoViewPicker;
  private photoSelectOptions: photoAccessHelper.PhotoSelectOptions;

  constructor(maxImageCount: number, limitOriginalFileSize?: number) {
    this.photoPicker = new photoAccessHelper.PhotoViewPicker();
    this.photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    this.photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    this.photoSelectOptions.maxSelectNumber = maxImageCount;
    this.limitOriginalFileSize = limitOriginalFileSize;
  }

  async openImagePicker(callback: ImagePickerCallback) {
    try {
      const photoSelectResult: photoAccessHelper.PhotoSelectResult =
        await this.photoPicker.select(this.photoSelectOptions);
      photoSelectResult.photoUris.forEach(async (uri: string) => {
        try {
          console.log(`select photo is ${uri}`)
          const chosenImage = await this.processImageResult(uri);
          callback.onResult(chosenImage);
        } catch (err) {
          if (err instanceof ImageProcessorError) {
            if (err.type === ValidationErrorType.FORMAT_UNSUPPORTED) {
              callback.onError?.(err.message);
            }
            if (err.type === ValidationErrorType.SIZE_EXCEEDED) {
              callback.onSizeLimitExceeded?.(err.message);
            }
          } else {

          }
        }
      });
    } catch (error) {

    }
  }

  private async processImageResult(uri: string): Promise<Optional<ChosenImage>> {
    ImageProcessor.getInstance().validateImageFile(uri, this.limitOriginalFileSize);

    const chosenImage = await ImageProcessor.getInstance().processImageUri(uri, new CompressParams());
    return chosenImage;
  }
}

export interface ImagePickerCallback {
  onResult: (chosenImage?: ChosenImage) => void,
  onError?: (message: string) => void,
  onSizeLimitExceeded?: (message: string) => void
}

@ObservedV2
export class ChosenImage {
  @Trace readonly path: string;
  readonly filename: string;
  readonly size: number;
  @Trace readonly base64: string;
  readonly type: string;
  readonly mime: string;
  readonly width?: number;
  readonly height?: number;

  constructor(
    path: string,
    filename: string,
    size: number,
    base64: string,
    type?: string,
    mime?: string,
    width?: number,
    height?: number
  ) {
    this.path = path;
    this.filename = filename;
    this.size = size ?? 0;
    this.base64 = base64 ?? '';
    this.type = type ?? 'image';
    this.mime = mime ?? 'image/jpeg';
    this.width = width;
    this.height = height;
  }
}