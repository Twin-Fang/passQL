import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ChevronRight, Flame, Sparkles } from "lucide-react";
import { useTopics } from "../hooks/useTopics";
import { getTopicIcon } from "../constants/topicIcons";
import { EmptyPracticeTopicError, generatePractice } from "../api/practice";
import { usePracticeStore } from "../stores/practiceStore";
import ErrorFallback from "../components/ErrorFallback";
import { useStagger } from "../hooks/useStagger";
import { useLatestTrendTopicCodes } from "../hooks/useExamTrend";
import LatestTrendBadge from "../components/LatestTrendBadge";

export default function CategoryCards() {
  const { data: topics, isLoading, isError, refetch } = useTopics();
  // 문제가 없는 카테고리 클릭 시 안내 모달 표시 여부
  const [showEmptyModal, setShowEmptyModal] = useState(false);
  const navigate = useNavigate();
  const startSession = usePracticeStore((s) => s.startSession);
  // 최신 경향 문제가 있는 토픽 (카드 배지, #523)
  const latestTrendTopicCodes = useLatestTrendTopicCodes();

  // 섹션별 순차 페이드인 딜레이 생성
  const stagger = useStagger();
  const s0 = stagger(0); // 제목 + 서브텍스트
  const s1 = stagger(1); // 카드 그리드

  const handleSelect = async (code: string, displayName: string) => {
    try {
      const { sessionId, questions } = await generatePractice(code);
      startSession(sessionId, code, displayName, questions);
      navigate(`/practice/${sessionId}`);
    } catch (err) {
      // 문제가 없는 카테고리인 경우 안내 모달 표시
      if (err instanceof EmptyPracticeTopicError) {
        setShowEmptyModal(true);
      } else {
        console.warn("[category cards] practice start failed", err);
      }
    }
  };

  if (isError) {
    return (
      <div className="py-6">
        <section className="mb-6">
          <h1 className="text-h1 mb-1 flex items-center gap-2">
            <Sparkles size={24} fill="currentColor" />
            AI문제 풀기
          </h1>
          <p className="text-secondary">
            골라보세요, AI가 딱 맞는 문제를 만들어드릴게요
          </p>
        </section>
        <ErrorFallback onRetry={() => refetch()} />
      </div>
    );
  }

  return (
    <div className="py-6">
      {/* CSS variable(--stagger-delay) 주입 — Tailwind로 표현 불가하여 style prop 예외 허용 */}
      {/* ① 제목 + 서브텍스트 */}
      <section className={s0.className}>
        <h1 className="text-h1 mb-1 flex items-center gap-2">
          <Sparkles size={24} fill="currentColor" />
          AI문제 풀기
        </h1>
        <p className="text-secondary mb-4">
          골라보세요, AI가 딱 맞는 문제를 만들어드릴게요
        </p>
        {/* 출제 경향 진입 (#523) */}
        <Link
          to="/exam-trend"
          className="mb-6 flex items-center gap-3 bg-surface-card border border-border rounded-2xl px-4 py-3 hover:border-brand transition-colors"
        >
          <Flame size={18} fill="currentColor" className="text-brand shrink-0" aria-hidden="true" />
          <span className="flex-1 min-w-0 text-sm text-text-primary">2026 출제 경향과 최신 경향 문제 보기</span>
          <ChevronRight size={16} className="text-text-caption shrink-0" aria-hidden="true" />
        </Link>
      </section>

      {/* ② 카드 그리드 */}
      {isLoading ? (
        <section className={`grid grid-cols-2 lg:grid-cols-3 gap-3 ${s1.className}`}>
          {Array.from({ length: 6 }, (_, i) => (
            <div key={i} className="card-topic pointer-events-none">
              {/* daisyUI skeleton — animate-pulse 대신 shimmer 효과 */}
              <div className="skeleton w-[52px] h-[52px] rounded-tile-large mb-3" />
              <div className="skeleton h-4 w-3/4 rounded" />
            </div>
          ))}
        </section>
      ) : (
        <section className={`grid grid-cols-2 lg:grid-cols-3 gap-3 ${s1.className}`}>
          {topics?.map((t) => {
            const Icon = getTopicIcon(t.code);
            return (
              <button
                key={t.code}
                type="button"
                className="card-topic"
                onClick={() => handleSelect(t.code, t.displayName)}
              >
                <div className="card-topic-icon">
                  <Icon size={26} className="text-brand" />
                </div>
                <span className="text-body font-bold">{t.displayName}</span>
                {latestTrendTopicCodes.has(t.code) && (
                  <span className="mt-2">
                    <LatestTrendBadge />
                  </span>
                )}
              </button>
            );
          })}
        </section>
      )}

      {/* 문제 없는 카테고리 클릭 시 안내 모달 — 센터 모달 */}
      {showEmptyModal && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-base-content/50 px-6"
          onClick={() => setShowEmptyModal(false)}
        >
          <div
            className="w-full max-w-[320px] bg-surface-card border border-border rounded-2xl px-6 py-7 space-y-4"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="space-y-1.5 text-center">
              <h2 className="text-lg font-bold text-text-primary">문제가 준비중이에요</h2>
              <p className="text-sm text-text-secondary">
                아직 이 카테고리의 문제가 등록되지 않았어요. 다른 카테고리를 먼저 시도해보세요.
              </p>
            </div>
            <button
              type="button"
              className="btn btn-primary w-full"
              onClick={() => setShowEmptyModal(false)}
            >
              확인
            </button>
          </div>
        </div>
      )}

    </div>
  );
}
