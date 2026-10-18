import { useEffect, useRef, useState } from "react";
import { ImageOff, X } from "lucide-react";
import { useCommunityImageUrl } from "../../hooks/useCommunityImageUrl";
import type { CommunityImage } from "../../types/api";

interface CommunityPostImagesProps {
  readonly images: readonly CommunityImage[];
}

/** 의견 첨부 사진: 썸네일 1~2장, 누르면 원본 확대 모달 */
export default function CommunityPostImages({ images }: CommunityPostImagesProps) {
  const [viewedImageUuid, setViewedImageUuid] = useState<string | null>(null);
  if (images.length === 0) return null;

  return (
    <>
      <div className="flex items-center gap-2">
        {images.map((image, index) => (
          <button
            key={image.imageUuid}
            type="button"
            className="w-24 h-24 shrink-0 rounded-xl overflow-hidden border border-border bg-surface"
            aria-label={`첨부 사진 ${index + 1} 크게 보기`}
            onClick={() => setViewedImageUuid(image.imageUuid)}
          >
            <CommunityImageView imageUuid={image.imageUuid} size="thumbnail" alternativeText={`첨부 사진 ${index + 1}`} />
          </button>
        ))}
      </div>
      {viewedImageUuid && (
        <CommunityImageViewerModal imageUuid={viewedImageUuid} onClose={() => setViewedImageUuid(null)} />
      )}
    </>
  );
}

interface CommunityImageViewProps {
  readonly imageUuid: string;
  readonly size: "thumbnail" | "full";
  readonly alternativeText: string;
}

/** 인증 이미지 한 장: 로딩 중 스켈레톤, 실패 시 아이콘 */
function CommunityImageView({ imageUuid, size, alternativeText }: CommunityImageViewProps) {
  const { objectUrl, isFailed } = useCommunityImageUrl(imageUuid, size);
  const isThumbnail = size === "thumbnail";

  if (isFailed) {
    return (
      <span className="w-full h-full flex items-center justify-center text-text-caption" role="img" aria-label="사진을 불러오지 못했어요">
        <ImageOff size={isThumbnail ? 20 : 32} aria-hidden="true" />
      </span>
    );
  }
  if (!objectUrl) return <span className="block w-full h-full animate-pulse bg-surface" aria-hidden="true" />;
  return (
    <img
      src={objectUrl}
      alt={alternativeText}
      className={isThumbnail ? "w-full h-full object-cover" : "max-w-full max-h-[80vh] object-contain rounded-xl"}
    />
  );
}

function CommunityImageViewerModal({ imageUuid, onClose }: { readonly imageUuid: string; readonly onClose: () => void }) {
  const closeButtonRef = useRef<HTMLButtonElement>(null);

  // ESC 닫기 + 배경 스크롤 잠금 + 닫기 버튼 포커스
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    closeButtonRef.current?.focus();
    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = previousOverflow;
    };
  }, [onClose]);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="relative flex items-center justify-center min-w-16 min-h-16"
        role="dialog"
        aria-modal="true"
        aria-label="첨부 사진 확대"
        onClick={(event) => event.stopPropagation()}
      >
        <CommunityImageView imageUuid={imageUuid} size="full" alternativeText="확대한 첨부 사진" />
        <button
          ref={closeButtonRef}
          type="button"
          className="absolute top-2 right-2 w-8 h-8 flex items-center justify-center rounded-full bg-surface-card text-text-primary border border-border"
          aria-label="닫기"
          onClick={onClose}
        >
          <X size={16} aria-hidden="true" />
        </button>
      </div>
    </div>
  );
}
