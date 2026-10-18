import { useEffect, useState } from "react";
import { Flag } from "lucide-react";
import {
  COMMUNITY_REPORT_CATEGORIES,
  COMMUNITY_REPORT_DETAIL_MAX_LENGTH,
  toCommunityErrorMessage,
} from "../../lib/communityPresentation";
import { useReportCommunityPost } from "../../hooks/useCommunity";

interface CommunityReportModalProps {
  readonly postUuid: string;
  readonly onClose: () => void;
  readonly onReported: () => void;
}

/** 의견 신고 시트: 사유 4종(단일 선택) + 선택 상세 */
export default function CommunityReportModal({ postUuid, onClose, onReported }: CommunityReportModalProps) {
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [detail, setDetail] = useState("");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const { mutate: report, isPending } = useReportCommunityPost();

  // ESC 닫기 + 배경 스크롤 잠금
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = previousOverflow;
    };
  }, [onClose]);

  const canSubmit = selectedCategory !== null && !isPending;

  const handleSubmit = () => {
    if (!selectedCategory || isPending) return;
    setErrorMessage(null);
    report(
      { postUuid, payload: { category: selectedCategory, detail: detail.trim() || null } },
      {
        onSuccess: onReported,
        onError: (error) => setErrorMessage(toCommunityErrorMessage(error, "신고하지 못했어요. 잠시 후 다시 시도해 주세요")),
      },
    );
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" role="dialog" aria-modal="true" aria-label="의견 신고" onClick={(event) => event.stopPropagation()}>
        <div className="flex items-center gap-2 mb-5">
          <div className="feedback-bar-icon--error w-7 h-7 rounded-full flex items-center justify-center shrink-0">
            <Flag size={13} className="feedback-bar-heading--error" />
          </div>
          <h3 className="font-bold text-lg text-text-primary">의견 신고</h3>
        </div>

        <div className="flex flex-col mb-5">
          {COMMUNITY_REPORT_CATEGORIES.map(({ value, label }) => {
            const isSelected = selectedCategory === value;
            return (
              <label
                key={value}
                className={`report-category-row ${isSelected ? "report-category-row--selected" : ""} ${isPending ? "opacity-60 cursor-not-allowed" : ""}`}
              >
                <span className={`report-radio ${isSelected ? "report-radio--selected" : ""}`}>
                  {isSelected && <span className="report-radio-dot" />}
                </span>
                <input
                  type="radio"
                  name="community-report-category"
                  className="sr-only"
                  checked={isSelected}
                  onChange={() => setSelectedCategory(value)}
                  disabled={isPending}
                />
                <span className={isSelected ? "report-category-label--selected" : "report-category-label"}>{label}</span>
              </label>
            );
          })}
          <textarea
            className="report-textarea mt-2"
            placeholder="자세한 내용이 있다면 적어 주세요 (선택)"
            rows={3}
            maxLength={COMMUNITY_REPORT_DETAIL_MAX_LENGTH}
            value={detail}
            onChange={(event) => setDetail(event.target.value)}
            disabled={isPending}
          />
        </div>

        {errorMessage && <p className="error-code-text text-sm mb-3">{errorMessage}</p>}

        <div className="flex gap-2">
          <button type="button" className="btn-cancel" onClick={onClose} disabled={isPending}>
            취소
          </button>
          <button type="button" className="btn-report" onClick={handleSubmit} disabled={!canSubmit}>
            {isPending ? <span className="loading loading-spinner loading-xs" /> : "신고하기"}
          </button>
        </div>
      </div>
    </div>
  );
}
