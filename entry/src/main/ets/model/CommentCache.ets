interface ICommentCache {
  text?: string;
  imageUri?: string;
}

export class CommentCache {
  private cacheMap = new Map<string, ICommentCache>();
  private static instance: CommentCache = new CommentCache();

  private constructor() {
  }

  static getInstance(): CommentCache {
    return CommentCache.instance;
  }

  save(commentId: string, comment: ICommentCache) {
    this.cacheMap.set(commentId, {
      text: comment.text?.trim(),
      imageUri: comment.imageUri
    });
  }

  getText(commentId: string) {
    return this.cacheMap.get(commentId)?.text;
  }

  setText(commentId: string, text: string) {
    const cache: ICommentCache = this.cacheMap.get(commentId) ?? {};
    cache.text = text.trim();
    this.cacheMap.set(commentId, cache);
  }

  getImageUri(commentId: string) {
    return this.cacheMap.get(commentId)?.imageUri;
  }

  setImageUri(commentId: string, imageUri: string) {
    const cache: ICommentCache = this.cacheMap.get(commentId) ?? {};
    cache.imageUri = imageUri;
    this.cacheMap.set(commentId, cache);
  }

  clear() {
    this.cacheMap.clear();
  }
}