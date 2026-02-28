import fs from '@ohos.file.fs';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ChosenImage } from './ImagePickerHelper';
import { util } from '@kit.ArkTS';

const TAG = 'ImageProcessor';

export class ImageProcessor {
  private static instance: ImageProcessor;

  static getInstance() {
    if (!ImageProcessor.instance) {
      ImageProcessor.instance = new ImageProcessor();
    }
    return ImageProcessor.instance;
  }

  async processImageUri(uri: string, params: CompressParams = new CompressParams()): Promise<Optional<ChosenImage>> {
    let file: fs.File | null = null;
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const arrayBuffer = await this.compressImg(file, params);
      const imageSourceApi = image.createImageSource(file.fd);
      const imageInfo = imageSourceApi.getImageInfoSync();
      imageSourceApi.release();

      const chosenImage: ChosenImage = new ChosenImage(
        uri,
        file.name,
        arrayBuffer.byteLength,
        new util.Base64Helper().encodeToStringSync(new Uint8Array(arrayBuffer), util.Type.BASIC),
        undefined,
        imageInfo.mimeType,
        imageInfo.size.width,
        imageInfo.size.height,
      );
      return chosenImage;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      return;
    } finally {
      if (file !== null) {
        fs.closeSync(file.fd);
      }
    }
  }

  validateImageFile(uri: string, limitOriginalFileSize: Optional<number>) {
    let file: fs.File | null = null;
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const imageSourceApi = image.createImageSource(file.fd);
      const imageInfo = imageSourceApi.getImageInfoSync();
      imageSourceApi.release();
      const stat = fs.statSync(file.fd);

      const fileName = file.name;
      const fileSize = stat.size;
      const mimeType = imageInfo.mimeType;

      this.validateImageCore(fileName, mimeType, fileSize, limitOriginalFileSize);
    } finally {
      if (file !== null) {
        fs.closeSync(file.fd);
      }
    }
  }

  private validateImageCore(fileName: string, mimeType: string, fileSize: number, limitFileSizeMB?: number) {
    if (this.isUnsupportedFormat(fileName, mimeType)) {
      throw new ImageProcessorError(ValidationErrorType.FORMAT_UNSUPPORTED, '暂不支持 GIF 动图格式，请选择其他图片格式');
    }
    if (this.isFileSizeExceeded(fileSize, limitFileSizeMB)) {
      throw new ImageProcessorError(ValidationErrorType.SIZE_EXCEEDED, `图片文件过大，请选择小于${limitFileSizeMB}MB的图片`);
    }
  }

  private isUnsupportedFormat(fileName: string, mimeType: string): boolean {
    return mimeType == 'image/gif' || fileName.toLowerCase().endsWith('.gif');
  }

  private isFileSizeExceeded(fileSize: number, limitFileSizeMB?: number) {
    if (!limitFileSizeMB || limitFileSizeMB < 0) {
      return false;
    }
    return fileSize > (limitFileSizeMB * 1024 * 1024);
  }

  /**
   * 图片压缩
   *
   * @param uri 图片uri
   * @param quality 压缩质量，取值范围0-100，压缩质量数字越大，图片越大
   * @returns ArrayBuffer
   */
  private async compressImg(file: fs.File, params: CompressParams): Promise<ArrayBuffer> {
    try {
      const validQuality = this.coerceIn(params.quality, 0, 100);
      const fileName = file.name;
      const stat = fs.statSync(file.fd);
      const arrayBuffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, arrayBuffer);

      if (fileName.toLowerCase().endsWith('.gif')) {
        return arrayBuffer;
      }

      if (params.minSizeToCompress > 0 && arrayBuffer.byteLength <= params.minSizeToCompress) {
        return arrayBuffer;
      }

      if (params.maxArea > 0) {
        this.compressImageWithMaxArea(arrayBuffer, params.maxArea);
      }

      const imageSource = image.createImageSource(arrayBuffer);
      const format = imageSource.getImageInfoSync().mimeType;
      // format支持image/jpeg,image/webp,image/png,image/heic,image/heif
      const packOpts: image.PackingOption = { format: format, quality: validQuality };
      const imagePackerApi: image.ImagePacker = image.createImagePacker();
      const buf = await imagePackerApi.packToData(imageSource, packOpts);
      imagePackerApi.release();
      return buf;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      return new ArrayBuffer(0);
    }
  }

  private compressImageWithMaxArea(arrayBuffer: ArrayBuffer, maxArea: number) {
    // todo area压缩未实现
  }

  private coerceIn(value: number, minimumValue: number, maximumValue: number): number {
    if (minimumValue > maximumValue) {
      return Math.min(minimumValue, maximumValue);
    }
    if (value < minimumValue) {
      return minimumValue;
    }
    if (value > maximumValue) {
      return maximumValue;
    }
    return value;
  }
}

export class CompressParams {
  // 最大面积限制，-1表示不限制
  maxArea: number = -1;
  // 最小压缩尺寸阈值，-1表示不限制
  minSizeToCompress: number = -1;
  // 压缩质量 0-100
  quality: number = 90;
}

export class ImageProcessorError extends Error {
  type: ValidationErrorType;

  constructor(type: ValidationErrorType, message: string) {
    super(message);
    this.type = type;
  }
}

export enum ValidationErrorType {
  FORMAT_UNSUPPORTED, SIZE_EXCEEDED
}