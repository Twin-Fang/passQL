import { useEffect } from "react";
import { createPortal } from "react-dom";
import { X } from "lucide-react";
import type { AppNotice } from "../types/api";

interface NoticeModalProps {
  readonly notice: Pick<AppNotice, "title" | "body">;
  readonly onClose: () => void;
}

/** 공지 본문 모달 (ESC·바깥 클릭·확인으로 닫기) (#464) */
export default function NoticeModal({ notice, onClose }: NoticeModalProps) {
  // ESC 닫기
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [onClose]);

  return createPortal(
    <div className="modal-overlay" onClick={onClose}>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="notice-modal-title"
        className="modal-card"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-3 mb-4">
          <h2 id="notice-modal-title" className="text-h2 text-text-primary break-keep">
            {notice.title}
          </h2>
          <button
            type="button"
            onClick={onClose}
            className="shrink-0 flex items-center justify-center w-7 h-7 rounded-full hover:bg-surface text-text-caption transition-colors"
            aria-label="닫기"
          >
            <X size={14} />
          </button>
        </div>
        {/* 본문 줄바꿈 유지, 긴 본문은 카드 안에서 스크롤 */}
        <p className="text-sm text-text-primary leading-relaxed whitespace-pre-line max-h-[60vh] overflow-y-auto">
          {notice.body}
        </p>
        <button type="button" className="btn btn-primary w-full mt-5" onClick={onClose}>
          확인
        </button>
      </div>
    </div>,
    document.body,
  );
}
