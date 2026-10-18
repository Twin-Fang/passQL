import { useRef } from "react";
import { ImagePlus, X } from "lucide-react";
import type { CommunityImageAttachment } from "../../hooks/useCommunityImageAttachments";
import { COMMUNITY_POST_MAX_IMAGE_COUNT } from "../../lib/communityImageCompression";
import { COMMUNITY_IMAGE_UNSUPPORTED_NOTICE } from "../../lib/communityPresentation";

interface CommunityImageAttachmentPickerProps {
  readonly attachments: readonly CommunityImageAttachment[];
  readonly isWebpSupported: boolean | null;
  readonly isPreparing: boolean;
  readonly isDisabled: boolean;
  readonly errorMessage: string | null;
  readonly onFilesSelected: (files: readonly File[]) => void;
  readonly onAttachmentRemoved: (attachmentId: string) => void;
}

/** 사진 첨부 영역: 추가 버튼(최대 2장) + 미리보기 + 제거, WebP 미지원 브라우저는 안내만 */
export default function CommunityImageAttachmentPicker({
  attachments,
  isWebpSupported,
  isPreparing,
  isDisabled,
  errorMessage,
  onFilesSelected,
  onAttachmentRemoved,
}: CommunityImageAttachmentPickerProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  if (isWebpSupported === null) return null;
  if (!isWebpSupported) return <p className="text-xs text-text-caption">{COMMUNITY_IMAGE_UNSUPPORTED_NOTICE}</p>;

  const canAddMore = attachments.length < COMMUNITY_POST_MAX_IMAGE_COUNT;

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    onFilesSelected(Array.from(event.target.files ?? []));
    // 같은 사진을 다시 고를 수 있게 비움
    event.target.value = "";
  };

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-2">
        {attachments.map((attachment, index) => (
          <div key={attachment.attachmentId} className="relative w-16 h-16 shrink-0">
            <img
              src={attachment.previewUrl}
              alt={`첨부 사진 ${index + 1}`}
              className="w-16 h-16 rounded-xl object-cover border border-border"
            />
            <button
              type="button"
              className="absolute -top-1.5 -right-1.5 w-5 h-5 flex items-center justify-center rounded-full bg-text-primary text-surface-card disabled:opacity-60"
              aria-label={`첨부 사진 ${index + 1} 제거`}
              disabled={isDisabled}
              onClick={() => onAttachmentRemoved(attachment.attachmentId)}
            >
              <X size={12} aria-hidden="true" />
            </button>
          </div>
        ))}
        {canAddMore && (
          <>
            <button
              type="button"
              className="btn btn-ghost btn-sm border border-border gap-1.5"
              disabled={isDisabled || isPreparing}
              onClick={() => fileInputRef.current?.click()}
            >
              {isPreparing ? <span className="loading loading-spinner loading-xs" /> : <ImagePlus size={14} aria-hidden="true" />}
              사진 추가 ({attachments.length}/{COMMUNITY_POST_MAX_IMAGE_COUNT})
            </button>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              multiple
              className="hidden"
              aria-label="사진 선택"
              onChange={handleFileChange}
            />
          </>
        )}
      </div>
      {errorMessage && <p role="alert" className="text-xs text-semantic-error-text">{errorMessage}</p>}
    </div>
  );
}
