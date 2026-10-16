import HomeRetryButton from "./HomeRetryButton";

interface HomeCardErrorProps {
  readonly title: string;
  readonly onRetry: () => void;
}

// 홈 카드 공통 실패 상태 — 히트맵 영역과 같은 문구·재시도 방식으로 맞춘다 (#399)
export default function HomeCardError({ title, onRetry }: HomeCardErrorProps) {
  return (
    <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 h-full flex flex-col justify-center gap-2">
      <p className="text-sm text-text-secondary">{title}</p>
      <p className="text-sm text-text-caption">불러오지 못했어요</p>
      <HomeRetryButton onRetry={onRetry} className="self-start" />
    </div>
  );
}
