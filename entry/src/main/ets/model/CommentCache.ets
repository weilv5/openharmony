import { ChosenImage } from '../utils/ImagePickerHelper';

interface ICommentCache {
  text?: string;
  image?: ChosenImage;
}

export class CommentCache {
  private cacheMap?: Map<string, ICommentCache>;
  private static instance: CommentCache;

  private constructor() {
  }

  static getInstance(): CommentCache {
    if (!CommentCache.instance) {
      CommentCache.instance = new CommentCache();
      CommentCache.instance.cacheMap = new Map<string, ICommentCache>();
    }
    return CommentCache.instance;
  }

  save(commentId: string, text?: string, image?: ChosenImage) {
    const cache: ICommentCache = this.cacheMap?.get(commentId) ?? {};
    cache.text = text?.trim();
    cache.image = image;
    this.cacheMap?.set(commentId, cache);
  }

  getText(commentId: string): Optional<string> {
    return this.cacheMap?.get(commentId)?.text;
  }

  getImage(commentId: string): Optional<ChosenImage> {
    return this.cacheMap?.get(commentId)?.image;
  }

  clear(commentId?: string): void {
    if (!commentId) {
      this.cacheMap?.clear();
    } else {
      this.cacheMap?.delete(commentId);
    }
  }
}