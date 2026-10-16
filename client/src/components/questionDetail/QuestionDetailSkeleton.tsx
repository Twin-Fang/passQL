interface QuestionDetailSkeletonProps {
  readonly isPracticeMode: boolean;
}

/**
 * 문제 로딩 스켈레톤: 헤더 1 + 지문 1 + 선택지 4
 */
export default function QuestionDetailSkeleton({ isPracticeMode }: QuestionDetailSkeletonProps) {
  // standalone 모드: 전체화면 컨테이너, practiceMode: 부모(DailyChallenge)가 컨테이너 제공
  const loadingClass = isPracticeMode
    ? "py-6 space-y-4"
    : "min-h-screen bg-surface py-6 space-y-4 max-w-120 mx-auto w-full px-4";
  return (
    <div className={loadingClass}>
      <div className="h-14 bg-border animate-pulse rounded" />
      <div className="h-24 bg-border animate-pulse rounded-xl" />
      <div className="space-y-3">
        {Array.from({ length: 4 }, (_, i) => (
          <div key={i} className="h-40 bg-border animate-pulse rounded-xl" />
        ))}
      </div>
    </div>
  );
}
