import SubpageLayout from "../components/SubpageLayout";
import WrongQuestionListState from "../components/wrongNotes/WrongQuestionListState";
import { useWrongQuestions } from "../hooks/useWrongQuestions";
import { WRONG_NOTES_PAGE_SIZE } from "../constants/wrongNotes";

// 로딩 스켈레톤 행 수
const WRONG_NOTES_SKELETON_ROW_COUNT = 6;

/**
 * 오답 노트 (#865, 앱 WrongNotesPage 대응): 최근 오답 20개 > 행별 다시 풀기
 * 진입: 마이페이지 전체보기, 통계 AI 분석 REVIEW_WRONG / 무료(결제 켜짐)는 잠금 미리보기
 */
export default function WrongNotes() {
  const wrongQuestions = useWrongQuestions(WRONG_NOTES_PAGE_SIZE);
  const items = wrongQuestions.data?.items ?? [];
  const totalWrongCount = wrongQuestions.data?.totalCount ?? 0;
  // 서버가 최근 N개만 주므로 전체 수가 더 많으면 범위 안내
  const isShowingRecentOnly = totalWrongCount > items.length;
  const hasError = wrongQuestions.error !== null;

  return (
    <SubpageLayout title="오답 노트">
      <div className="max-w-2xl mx-auto space-y-3">
        {totalWrongCount > 0 && (
          <p className="px-1 text-sm text-text-secondary">
            틀린 문제 <span className="font-semibold text-semantic-error-text tabular-nums">{totalWrongCount}개</span>
            {isShowingRecentOnly && <span className="text-text-caption"> · 최근 {items.length}개</span>}
          </p>
        )}
        {/* 목록·빈·로딩은 카드 안, 잠금·오류는 자체 카드라 바로 그림 */}
        <section aria-label="오답 목록" className={hasError ? "" : "bg-surface-card border border-border rounded-2xl overflow-hidden"}>
          <WrongQuestionListState
            isLoading={wrongQuestions.isLoading}
            error={wrongQuestions.error}
            items={items}
            skeletonRowCount={WRONG_NOTES_SKELETON_ROW_COUNT}
            isInsideCard={!hasError}
            onRetry={() => void wrongQuestions.refetch()}
          />
        </section>
      </div>
    </SubpageLayout>
  );
}
