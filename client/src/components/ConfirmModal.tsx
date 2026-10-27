import { useEffect, useState } from "react";

interface ConfirmModalProps {
  readonly isOpen: boolean;
  readonly title: string;
  readonly description: string;
  // 파괴적 액션 레이블 (예: "나가기") — Secondary 버튼
  readonly confirmLabel: string;
  // 유지 액션 레이블 (예: "계속 풀기") — Primary 버튼
  readonly cancelLabel: string;
  readonly onConfirm: () => void;
  readonly onCancel: () => void;
  // 주면 이 문구를 그대로 입력해야 확인 버튼이 눌린다 — 탈퇴처럼 실수로 누르면 안 되는 동작
  readonly requiredText?: string;
}

export default function ConfirmModal({
  isOpen,
  title,
  description,
  confirmLabel,
  cancelLabel,
  onConfirm,
  onCancel,
  requiredText,
}: ConfirmModalProps) {
  const [typedText, setTypedText] = useState("");
  const canConfirm = requiredText === undefined || typedText.trim() === requiredText;

  // 다시 열 때 지난 입력이 남아 있으면 바로 눌릴 수 있어 닫힐 때 비운다
  useEffect(() => {
    if (!isOpen) setTypedText("");
  }, [isOpen]);

  // ESC 키로 모달 닫기 + 배경 스크롤 잠금
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onCancel();
    };
    window.addEventListener("keydown", handleKeyDown);
    // 이전 overflow 값 저장 후 복원 — 중첩 모달 대응
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = previousOverflow;
    };
  }, [isOpen, onCancel]);

  if (!isOpen) return null;

  return (
    // 오버레이 — 클릭 시 이탈 취소
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-base-content/50"
      onClick={onCancel}
    >
      {/* 모달 카드 — 클릭 이벤트 버블링 방지 */}
      <div
        className="w-full bg-surface-card border border-border rounded-t-2xl px-5 pt-5 pb-8 space-y-4"
        onClick={(e) => e.stopPropagation()}
      >
        {/* 상단 인디케이터 */}
        <div className="w-10 h-1 bg-border rounded-full mx-auto" />

        <div className="space-y-1.5 text-center">
          <h2 className="text-lg font-bold text-text-primary">{title}</h2>
          <p className="text-sm text-text-secondary">{description}</p>
        </div>

        {requiredText !== undefined && (
          <label className="block space-y-1.5">
            <span className="block text-sm text-text-secondary text-center">
              계속하려면 '{requiredText}'를 입력해 주세요.
            </span>
            <input
              type="text"
              className="input input-bordered w-full"
              placeholder={requiredText}
              value={typedText}
              onChange={(e) => setTypedText(e.target.value)}
              autoFocus
            />
          </label>
        )}

        <div className="flex flex-col gap-2">
          {/* 유지 액션: Primary 버튼 (파괴적 액션 비강조 원칙) */}
          <button
            type="button"
            className="btn btn-primary w-full"
            onClick={onCancel}
          >
            {cancelLabel}
          </button>
          {/* 파괴적 액션: Secondary 버튼 */}
          <button
            type="button"
            className="btn btn-secondary w-full"
            onClick={onConfirm}
            disabled={!canConfirm}
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
