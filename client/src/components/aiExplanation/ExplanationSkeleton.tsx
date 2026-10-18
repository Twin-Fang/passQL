// 줄 폭 (글 줄처럼 들쭉날쭉, 마지막 줄 짧게)
const LINE_WIDTH_CLASSES_BY_COUNT = {
  2: ["w-full", "w-3/5"],
  3: ["w-full", "w-11/12", "w-2/3"],
} as const;

interface ExplanationSkeletonProps {
  readonly lineCount?: 2 | 3;
}

/**
 * AI 해설 기다림 자리: 텍스트 줄 모양 한 블록 + 반짝임 1개 (동작 줄이기면 정지)
 */
export default function ExplanationSkeleton({ lineCount = 3 }: ExplanationSkeletonProps) {
  return (
    <div className="explanation-skeleton space-y-2 py-1" role="status" aria-label="AI 해설을 준비하고 있어요">
      {LINE_WIDTH_CLASSES_BY_COUNT[lineCount].map((widthClass) => (
        <div key={widthClass} className={`explanation-skeleton-line ${widthClass}`} />
      ))}
    </div>
  );
}
