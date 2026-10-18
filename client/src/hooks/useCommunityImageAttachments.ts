import { useCallback, useEffect, useRef, useState } from "react";
import {
  COMMUNITY_POST_MAX_IMAGE_COUNT,
  CommunityImageCompressionError,
  checkWebpEncodingSupport,
  prepareCommunityImage,
} from "../lib/communityImageCompression";

export interface CommunityImageAttachment {
  readonly attachmentId: string;
  readonly image: Blob;
  readonly thumbnail: Blob;
  /** 선택 미리보기 (썸네일 Blob 의 object URL) */
  readonly previewUrl: string;
}

const PREPARE_FAILED_MESSAGE = "사진을 준비하지 못했어요. 다른 사진을 선택해 주세요";

/** 의견 작성의 사진 선택 상태: WebP 지원 확인, 압축, 최대 2장, 미리보기 URL 정리 */
export function useCommunityImageAttachments() {
  const [attachments, setAttachments] = useState<readonly CommunityImageAttachment[]>([]);
  const [isWebpSupported, setIsWebpSupported] = useState<boolean | null>(null);
  const [isPreparing, setIsPreparing] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const attachmentsRef = useRef(attachments);

  useEffect(() => {
    attachmentsRef.current = attachments;
  }, [attachments]);

  useEffect(() => {
    let isCancelled = false;
    void checkWebpEncodingSupport().then((isSupported) => !isCancelled && setIsWebpSupported(isSupported));
    return () => {
      isCancelled = true;
    };
  }, []);

  // 화면을 떠날 때 남은 미리보기 URL 해제
  useEffect(
    () => () => attachmentsRef.current.forEach(({ previewUrl }) => URL.revokeObjectURL(previewUrl)),
    [],
  );

  const addFiles = useCallback(async (files: readonly File[]) => {
    const remainingCount = COMMUNITY_POST_MAX_IMAGE_COUNT - attachmentsRef.current.length;
    if (files.length === 0 || remainingCount <= 0) return;
    setErrorMessage(null);
    setIsPreparing(true);
    const preparedAttachments: CommunityImageAttachment[] = [];
    try {
      for (const file of files.slice(0, remainingCount)) {
        const { image, thumbnail } = await prepareCommunityImage(file);
        preparedAttachments.push({ attachmentId: crypto.randomUUID(), image, thumbnail, previewUrl: URL.createObjectURL(thumbnail) });
      }
    } catch (error) {
      setErrorMessage(error instanceof CommunityImageCompressionError ? error.message : PREPARE_FAILED_MESSAGE);
    } finally {
      // 앞에서 성공한 사진은 뒤 사진이 실패해도 유지
      setAttachments((current) => [...current, ...preparedAttachments]);
      setIsPreparing(false);
    }
  }, []);

  const removeAttachment = useCallback((attachmentId: string) => {
    setAttachments((current) => {
      current.filter((attachment) => attachment.attachmentId === attachmentId).forEach(({ previewUrl }) => URL.revokeObjectURL(previewUrl));
      return current.filter((attachment) => attachment.attachmentId !== attachmentId);
    });
  }, []);

  const clearAttachments = useCallback(() => {
    attachmentsRef.current.forEach(({ previewUrl }) => URL.revokeObjectURL(previewUrl));
    setAttachments([]);
  }, []);

  return { attachments, isWebpSupported, isPreparing, errorMessage, addFiles, removeAttachment, clearAttachments };
}
