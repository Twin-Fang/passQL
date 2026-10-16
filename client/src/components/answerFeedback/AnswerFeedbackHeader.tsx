interface AnswerFeedbackHeaderProps {
  readonly isCorrect: boolean;
}

/**
 * 채점 결과 헤더: 상단 3px 컬러 바 + 도트 상태 eyebrow + 제목
 */
export default function AnswerFeedbackHeader({ isCorrect }: AnswerFeedbackHeaderProps) {
  return (
    <div className="bg-base-100 border-b border-base-200 feedback-header-anim">
      {/* 상단 3px 컬러 바 — 좌→우 슬라이드인 */}
      <div
        className={`h-0.75 w-full feedback-bar-anim ${
          isCorrect ? "bg-success" : "bg-error"
        }`}
      />
      <div className="px-4 pt-4 pb-4">
        {/* 도트 + 상태 eyebrow */}
        <div className="flex items-center gap-1.5 mb-1.5">
          <span
            className={`inline-block w-1.75 h-1.75 rounded-full shrink-0 ${
              isCorrect ? "bg-success" : "bg-error"
            }`}
          />
          <span
            className={`text-xs font-semibold tracking-wide ${
              isCorrect ? "text-success" : "text-error"
            }`}
          >
            {isCorrect ? "정답" : "오답"}
          </span>
        </div>
        {/* 큰 제목 */}
        <h1 className="text-xl font-bold text-base-content">
          {isCorrect ? "맞혔어요!" : "틀렸어요"}
        </h1>
        {/* 부제목 */}
        <p className="text-sm text-base-content/50 mt-1">
          {isCorrect
            ? "잘 맞혔어요. 다음 문제도 도전해보세요"
            : "해설을 확인하고 다시 도전해보세요"}
        </p>
      </div>
    </div>
  );
}
