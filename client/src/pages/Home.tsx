import { useProgress } from "../hooks/useProgress";
import { useMember } from "../hooks/useMember";
import { useAuthStore } from "../stores/authStore";
import {
  useGreeting,
  useDailySet,
  useRecommendations,
  useSelectedSchedule,
  useHeatmap,
} from "../hooks/useHome";
import { useStagger } from "../hooks/useStagger";
import { useRecommendationRefresh } from "../hooks/useRecommendationRefresh";
import AppDownloadBanner from "../components/AppDownloadBanner";
import HomeGreeting from "../components/home/HomeGreeting";
import ExamScheduleCard from "../components/home/ExamScheduleCard";
import DailySetCard from "../components/home/DailySetCard";
import StudyStatusSection from "../components/home/StudyStatusSection";
import ReadinessSection from "../components/home/ReadinessSection";
import RecommendedQuestionsSection from "../components/home/RecommendedQuestionsSection";
import ExamTrendEntryCard from "../components/home/ExamTrendEntryCard";
import TodayDiscussionCard from "../components/home/TodayDiscussionCard";

/**
 * 홈: 인사말 > 시험 일정·데일리 세트 > 학습 현황 > 합격 준비도 > AI 추천문제
 * 섹션별 독립 로딩·에러 처리
 */
export default function Home() {
  const stagger = useStagger();
  // 각 섹션의 stagger 결과를 미리 선언 — 동일 인덱스 이중 호출 방지
  const s0 = stagger(0); // 그리팅 줄1
  const s1 = stagger(1); // 그리팅 줄2 + 서브메시지
  const s2 = stagger(2); // 오늘의 문제 + 시험 일정
  const s3 = stagger(3); // 학습 현황
  const s4 = stagger(4); // 합격 준비도 / 통계
  const s5 = stagger(5); // AI 추천문제

  // 각 훅의 상태를 개별 구조분해 — 섹션별 독립 에러/로딩 처리를 위해
  const {
    data: progress,
    isLoading: progressLoading,
    isError: progressError,
    refetch: refetchProgress,
  } = useProgress();
  useMember();
  const { data: greeting } = useGreeting();
  // 실패를 빈 데이터처럼 보여주지 않도록 로딩·에러를 함께 받는다 (#399)
  const {
    data: dailySet,
    isLoading: dailySetLoading,
    isError: dailySetError,
    refetch: refetchDailySet,
  } = useDailySet();
  const {
    data: recommendations,
    isLoading: recommendationsLoading,
    isError: recommendationsError,
    isFetching: recommendationsFetching,
  } = useRecommendations();
  const recommendationRefresh = useRecommendationRefresh(recommendations?.questions, recommendationsFetching);
  const {
    data: schedule,
    isLoading: scheduleLoading,
    isError: scheduleError,
    refetch: refetchSchedule,
  } = useSelectedSchedule();
  const {
    data: heatmap,
    isLoading: heatmapLoading,
    isError: heatmapError,
    refetch: refetchHeatmap,
  } = useHeatmap();

  const uuid = useAuthStore((s) => s.memberUuid ?? "");
  const nickname = useAuthStore((s) => s.nickname ?? "");
  const displayName = nickname || uuid.slice(0, 8);

  // 추천 문제: 에러 시 숨김, 초기 로딩 또는 추천 1개 이상일 때 표시
  const shouldShowRecommendations =
    !recommendationsError && (recommendationsLoading || (recommendations && recommendations.questions.length > 0));

  return (
    <div className="py-6 space-y-0">
      <HomeGreeting
        greeting={greeting}
        displayName={displayName}
        firstLineClassName={s0.className}
        restLinesClassName={s1.className}
      />

      {/* ③ 시험 일정 + 오늘의 문제 카드 섹션 — 시험 일정을 앞에 배치 */}
      {/* 앱 출시 안내 — 스토어 링크가 설정됐을 때만 보인다 (#433) */}
      <AppDownloadBanner />

      <section className={`grid grid-cols-1 sm:grid-cols-2 gap-3 mb-4 ${s2.className}`}>
        <ExamScheduleCard
          schedule={schedule}
          isLoading={scheduleLoading}
          isError={scheduleError}
          onRetry={() => refetchSchedule()}
        />
        <DailySetCard
          dailySet={dailySet}
          isLoading={dailySetLoading}
          isError={dailySetError}
          onRetry={() => refetchDailySet()}
        />
      </section>

      {/* 출제 경향 진입 (#523) */}
      <ExamTrendEntryCard className={s2.className} />

      {/* 오늘의 토론 (#525): HOT 1위가 없으면 숨김 */}
      <TodayDiscussionCard className={s2.className} />

      {/* ④ 학습 현황 섹션: heatmap 에러/로딩만 독립 처리 */}
      <StudyStatusSection
        streakDays={progress?.streakDays ?? 0}
        heatmap={heatmap}
        isHeatmapLoading={heatmapLoading}
        isHeatmapError={heatmapError}
        onRetryHeatmap={() => refetchHeatmap()}
        staggerClassName={s3.className}
      />

      {/* ⑤ 합격 준비도 / 통계 섹션: progress 에러/로딩 독립 처리 */}
      <ReadinessSection
        progress={progress}
        isLoading={progressLoading}
        isError={progressError}
        onRetry={() => refetchProgress()}
        staggerClassName={s4.className}
      />

      {/* ⑥ 추천 문제 섹션: 에러 시 숨김, 초기 로딩 시 스켈레톤 표시 */}
      {shouldShowRecommendations && (
        <RecommendedQuestionsSection
          questions={recommendations?.questions}
          isLoading={recommendationsLoading}
          isRefreshDisabled={recommendationRefresh.isRefreshDisabled}
          isSpinning={recommendationRefresh.isSpinning}
          refreshKey={recommendationRefresh.refreshKey}
          onRefresh={recommendationRefresh.refresh}
          onSpinEnd={recommendationRefresh.stopSpinning}
          staggerClassName={s5.className}
        />
      )}
    </div>
  );
}
