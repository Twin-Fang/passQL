import { useId } from "react";
import { createPortal } from "react-dom";
import { X } from "lucide-react";
import ProAccessReasonContent from "./ProAccessReasonContent";
import type { ProAccessErrorCode } from "../../lib/proAccess";
import { useCloseOnEscape } from "../../hooks/useCloseOnEscape";

interface ProAccessReasonModalProps {
  readonly errorCode: ProAccessErrorCode;
  readonly onClose: () => void;
}

/**
 * 프로 접근 사유 창 (#865): 버튼 동작(토픽 연습 시작·연습 제출)이 403·429 로 막혔을 때 사유 화면 본문을 창으로
 * 닫으면 원래 화면 유지 (ESC·바깥 클릭·닫기 버튼)
 */
export default function ProAccessReasonModal({ errorCode, onClose }: ProAccessReasonModalProps) {
  const titleId = useId();

  useCloseOnEscape(onClose);

  return createPortal(
    <div className="modal-overlay" onClick={onClose}>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className="modal-card relative pt-8 pb-6"
        onClick={(event) => event.stopPropagation()}
      >
        <button
          type="button"
          onClick={onClose}
          className="absolute top-3 right-3 flex items-center justify-center w-7 h-7 rounded-full hover:bg-surface text-text-caption transition-colors"
          aria-label="닫기"
        >
          <X size={14} />
        </button>
        <ProAccessReasonContent errorCode={errorCode} titleId={titleId} />
      </div>
    </div>,
    document.body,
  );
}
