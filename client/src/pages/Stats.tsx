import { useState, useRef, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { CheckSquare, BarChart2, Zap, HelpCircle } from "lucide-react";
import { useProgress } from "../hooks/useProgress";
import { fetchTopicAnalysis, fetchAiComment } from "../api/progress";
import { useAuthStore } from "../stores/authStore";
import ErrorFallback from "../components/ErrorFallback";
import StatsAnalysisCard from "../components/StatsAnalysisCard";
import StatsRadarChart from "../components/StatsRadarChart";
import StatsTopicList from "../components/StatsTopicList";
import AnchoredPopover from "../components/AnchoredPopover";
import ProgressBar from "../components/ProgressBar";
import { useStagger } from "../hooks/useStagger";
import type { ReadinessResponse } from "../types/api";

// 합격 준비도 팝오버 폭 (px)
const READINESS_POPOVER_WIDTH_PIXELS = 224;

function ReadinessPopover({
  readiness,
  open,
  anchorRef,
}: {
  readiness: ReadinessResponse;
  open: boolean;
  anchorRef: React.RefObject<HTMLButtonElement | null>;
}) {
  return (
    <AnchoredPopover isOpen={open} anchorRef={anchorRef} widthPixels={READINESS_POPOVER_WIDTH_PIXELS} alignment="center">
      <p className="text-xs font-bold mb-2">합격 준비도란?</p>
      <p className="text-xs text-text-inverse-secondary leading-relaxed mb-3">
        정답률 · 공부 범위를 곱한 기본 점수에, 오답 복습과 고른 학습 보너스를 더한 점수예요.
      </p>
      <div className="flex flex-col gap-1.5">
        {[
          { label: "맞힌 비율", value: readiness.accuracy },
          { label: "공부 범위", value: readiness.coverage },
          { label: "꾸준함",    value: readiness.recency },
          { label: "오답 복습", value: readiness.retry },
          { label: "고른 학습", value: readiness.spread },
        ].map(({ label, value }) => (
          <div key={label} className="flex items-center gap-2">
            <span className="text-caption2 text-text-inverse-secondary w-16 shrink-0">{label}</span>
            <ProgressBar
              fillPercent={Math.round(value * 100)}
              trackClassName="flex-1 h-1 bg-text-inverse/15"
              fillClassName="bg-brand-medium"
            />
            <span className="text-caption2 text-brand-medium w-7 text-right shrink-0">
              {Math.round(value * 100)}%
            </span>
          </div>
        ))}
      </div>
    </AnchoredPopover>
  );
}

export default function Stats() {
  const [readinessPopoverOpen, setReadinessPopoverOpen] = useState(false);
  const readinessBtnRef = useRef<HTMLButtonElement>(null);
  // UUID 없이 호출하면 400이므로 enabled 가드 필수
  const uuid = useAuthStore((s) => s.memberUuid ?? "");

  const {
    data: progress,
    isLoading: progressLoading,
    isError,
    refetch,
  } = useProgress();

  // 토픽별 정답률/풀이 수 (레이더·리스트)
  const { data: topicAnalysis } = useQuery({
    queryKey: ["topicAnalysis", uuid],
    queryFn: fetchTopicAnalysis,
    enabled: !!uuid,
    staleTime: 1000 * 60 * 5,
  });

  // 토픽 데이터 있을 때만 AI 코멘트 카드 렌더 > 없으면 LLM 호출 생략
  const hasTopicStats = (topicAnalysis?.topicStats.length ?? 0) > 0;

  // AI 코멘트 — Stats 페이지는 세션 무관 전체 분석이므로 sessionUuid 빈 문자열 전달
  const { data: aiComment, isLoading: aiCommentLoading } = useQuery({
    queryKey: ["aiComment", uuid],
    queryFn: () => fetchAiComment(),
    enabled: !!uuid && hasTopicStats,
    staleTime: 1000 * 60 * 60,
    gcTime: 1000 * 60 * 60, // staleTime 과 동일: 탭 이탈 후 재진입 시 LLM 재호출 방지
  });

  const readiness = progress?.readiness;
  const readinessPercent = readiness ? Math.round(readiness.score * 100) : null;
  const topicStats = topicAnalysis?.topicStats ?? [];

  // 팝오버 바깥 클릭 시 닫기
  useEffect(() => {
    if (!readinessPopoverOpen) return;
    const handler = (e: MouseEvent) => {
      if (readinessBtnRef.current?.contains(e.target as Node)) return;
      setReadinessPopoverOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [readinessPopoverOpen]);

  // 섹션별 순차 페이드인 딜레이
  const stagger = useStagger();
  const s0 = stagger(0);
  const s1 = stagger(1);
  const s2 = stagger(2);
  const s3 = stagger(3);
  const s4 = stagger(4);

  if (progressLoading) {
    return (
      <div className="py-6 space-y-6">
        <div className="h-24 rounded-xl bg-border animate-pulse" />
        <div className="h-20 rounded-xl bg-border animate-pulse" />
        <div className="h-64 rounded-xl bg-border animate-pulse" />
      </div>
    );
  }

  // 에러 시 헤딩은 보여주고 에러 카드만 아래에 배치
  if (isError) {
    return (
      <div className="py-6 space-y-6">
        <section>
          <h1 className="text-h1">내 실력, 한눈에</h1>
          <p className="text-secondary mt-1">약한 영역을 눌러 바로 연습해보세요</p>
        </section>
        <ErrorFallback onRetry={() => refetch()} />
      </div>
    );
  }

  return (
    <div className="py-6 space-y-6">
      {/* ① 제목 + 서브텍스트 */}
      <section className={s0.className}>
        <h1 className="text-h1">내 실력, 한눈에</h1>
        <p className="text-secondary mt-1">약한 영역을 눌러 바로 연습해보세요</p>
      </section>

      {/* ② 상단 요약 카드 */}
      <section className={`bg-surface-card border border-border rounded-2xl p-0 ${s1.className}`}>
        <div className="flex divide-x divide-border">

          {/* 푼 문제 */}
          <div className="flex-1 text-center py-5 px-2">
            <div className="w-9 h-9 rounded-tile bg-brand-light flex items-center justify-center mx-auto mb-2">
              <CheckSquare size={18} className="text-brand" />
            </div>
            <p className="text-h1 text-2xl">{progress?.solvedCount ?? 0}문제</p>
            <p className="text-secondary text-footnote mt-0.5">푼 문제</p>
          </div>

          {/* 합격 준비도 / 정답률 */}
          <div className="flex-1 text-center py-5 px-2 relative">
            <div className="w-9 h-9 rounded-tile bg-brand-light flex items-center justify-center mx-auto mb-2">
              <BarChart2 size={18} className="text-brand" />
            </div>
            <p className="text-h1 text-2xl">
              {readinessPercent != null
                ? `${readinessPercent}%`
                : `${Math.round((progress?.correctRate ?? 0) * 100)}%`}
            </p>
            <div className="flex items-center justify-center gap-1 mt-0.5">
              <p className="text-secondary text-footnote">
                {readinessPercent != null ? "합격 준비도" : "정답률"}
              </p>
              {readiness && (
                <>
                  <button
                    ref={readinessBtnRef}
                    onClick={() => setReadinessPopoverOpen((v) => !v)}
                    className="w-4 h-4 rounded-full bg-surface-code flex items-center justify-center shrink-0"
                    aria-label="합격 준비도 설명"
                  >
                    <HelpCircle size={10} className="text-text-caption" />
                  </button>
                  <ReadinessPopover
                    readiness={readiness}
                    open={readinessPopoverOpen}
                    anchorRef={readinessBtnRef}
                  />
                </>
              )}
            </div>
          </div>

          {/* 연속 학습 */}
          <div className="flex-1 text-center py-5 px-2">
            <div className="w-9 h-9 rounded-tile bg-semantic-warning-light flex items-center justify-center mx-auto mb-2">
              <Zap size={18} className="text-semantic-warning" />
            </div>
            <p className="text-h1 text-2xl">{progress?.streakDays ?? 0}일</p>
            <p className="text-secondary text-footnote mt-0.5">연속 학습</p>
          </div>

        </div>
      </section>

      {topicStats.length > 0 ? (
        <>
          {/* ③ AI 코멘트 */}
          <section className={s2.className}>
            <StatsAnalysisCard
              comment={aiComment?.comment ?? null}
              isLoading={aiCommentLoading}
            />
          </section>
          {/* ④ 레이더 차트 */}
          <section className={s3.className}>
            <StatsRadarChart topicStats={topicStats} />
          </section>
          {/* ⑤ 토픽별 학습 현황 */}
          <section className={s4.className}>
            <StatsTopicList topicStats={topicStats} />
          </section>
        </>
      ) : (
        <section className={`bg-surface-card border border-border rounded-2xl text-center py-12 ${s2.className}`}>
          <p className="text-text-caption">아직 풀이 기록이 없어요</p>
          <p className="text-xs text-text-caption mt-1">
            문제를 풀면 여기에 실력이 나타나요
          </p>
        </section>
      )}
    </div>
  );
}
