import { RefreshCw } from "lucide-react";

interface HomeRetryButtonProps {
  readonly onRetry: () => void;
  // 배치용 추가 클래스 (예: self-start)
  readonly className?: string;
}

/**
 * 홈 카드 실패 상태 공통 재시도 버튼 (시험 일정·데일리 세트·히트맵·합격 준비도)
 */
export default function HomeRetryButton({ onRetry, className }: HomeRetryButtonProps) {
  return (
    <button
      type="button"
      className={`btn-compact inline-flex items-center gap-1.5${className ? ` ${className}` : ""}`}
      onClick={onRetry}
    >
      <RefreshCw size={12} />
      재시도
    </button>
  );
}
