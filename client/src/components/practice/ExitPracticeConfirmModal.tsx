import ConfirmModal from "../ConfirmModal";

interface ExitPracticeConfirmModalProps {
  readonly isOpen: boolean;
  readonly onCancel: () => void;
  readonly onConfirm: () => void;
}

/**
 * 풀이 이탈 확인 모달: 문구 고정 (풀이 화면 4곳 공통)
 */
export default function ExitPracticeConfirmModal({ isOpen, onCancel, onConfirm }: ExitPracticeConfirmModalProps) {
  return (
    <ConfirmModal
      isOpen={isOpen}
      title="풀이를 그만할까요?"
      description="지금 나가면 현재 풀이 기록이 저장되지 않아요."
      cancelLabel="계속 풀기"
      confirmLabel="나가기"
      onCancel={onCancel}
      onConfirm={onConfirm}
    />
  );
}
