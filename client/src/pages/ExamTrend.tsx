import { useNavigate } from "react-router-dom";
import { ChevronRight, Lightbulb } from "lucide-react";
import { useLatestExamTrend } from "../hooks/useExamTrend";
import { EmptyPracticeTopicError, generatePractice } from "../api/practice";
import { usePracticeStore } from "../stores/practiceStore";
import ErrorFallback from "../components/ErrorFallback";
import LockedPreview from "../components/pro/LockedPreview";
import { ExamTrendLockedSample } from "../components/pro/lockedPreviewSamples";
import { LOCKED_PREVIEW_CAPTIONS } from "../constants/proAccessCopy";
import { toProAccessErrorCode } from "../lib/proAccess";
import LatestTrendBadge from "../components/LatestTrendBadge";
import ProgressBar from "../components/ProgressBar";
import { useStagger } from "../hooks/useStagger";

/** 유형·개념 공통 행 모양 (탭 > 해당 토픽 최신 경향 풀기) */
interface SolvableTrendItem {
  readonly key: string;
  readonly title: string;
  readonly caption: string;
  readonly description: string;
  readonly topicCode: string;
  readonly topicName: string | null;
  readonly latestTrendQuestionCount: number;
}

/**
 * 출제 경향 (#523): 요약 > 과목 비중 > 늘어난 유형 > 자주 나오는 개념 > 공부 팁
 * 최신 경향 문제가 있는 항목만 풀기 버튼 > 그 토픽 최신 경향 연습 세션
 */
export default function ExamTrend() {
  const { data: report, isLoading, isError, error, refetch } = useLatestExamTrend();
  const navigate = useNavigate();
  const startSession = usePracticeStore((s) => s.startSession);
  const stagger = useStagger();
  const s0 = stagger(0); // 요약
  const s1 = stagger(1); // 과목 비중·유형
  const s2 = stagger(2); // 개념·팁

  // 토픽 최신 경향 문제로 연습 세션 시작 (문제 0개·조회 실패면 화면 유지, AI문제 화면과 같은 처리)
  const startLatestTrendPractice = async (topicCode: string, topicName: string) => {
    try {
      const { sessionId, questions } = await generatePractice(topicCode, { isLatestTrendOnly: true });
      startSession(sessionId, topicCode, `${topicName} 최신 경향`, questions);
      navigate(`/practice/${sessionId}`);
    } catch (err) {
      if (!(err instanceof EmptyPracticeTopicError)) console.debug("[exam trend] practice start failed", err);
    }
  };

  if (isError) {
    // 프로 필요(무료, 결제 켜짐) > 잠금 미리보기, 그 외 오류 > 다시 시도 (#578)
    const isProRequired = toProAccessErrorCode(error) === "PRO_REQUIRED";
    return (
      <div className="py-6">
        <h1 className="text-h1 mb-4">출제 경향</h1>
        {isProRequired ? (
          <LockedPreview preview={<ExamTrendLockedSample />} caption={LOCKED_PREVIEW_CAPTIONS.examTrend} />
        ) : (
          <ErrorFallback onRetry={() => refetch()} />
        )}
      </div>
    );
  }

  if (isLoading || !report) {
    return (
      <div className="py-6 space-y-3" aria-busy="true">
        <div className="skeleton h-40 rounded-2xl" />
        <div className="skeleton h-32 rounded-2xl" />
        <div className="skeleton h-64 rounded-2xl" />
      </div>
    );
  }

  const patternItems: SolvableTrendItem[] = report.risingPatterns.map((pattern) => ({
    key: `pattern-${pattern.title}`,
    title: pattern.title,
    caption: pattern.examRoundsText,
    description: pattern.description,
    topicCode: pattern.topicCode,
    topicName: pattern.topicName,
    latestTrendQuestionCount: pattern.latestTrendQuestionCount,
  }));
  const conceptItems: SolvableTrendItem[] = report.frequentConcepts.map((concept) => ({
    key: `concept-${concept.rank}`,
    title: `${concept.rank}. ${concept.name}`,
    caption: concept.frequencyText,
    description: concept.description,
    topicCode: concept.topicCode,
    topicName: concept.topicName,
    latestTrendQuestionCount: concept.latestTrendQuestionCount,
  }));

  return (
    <div className="py-6 space-y-6">
      {/* 요약 */}
      <section className={`bg-surface-card border border-border rounded-2xl p-5 sm:p-6 ${s0.className}`}>
        <LatestTrendBadge />
        <h1 className="text-h1 mt-2">{report.title}</h1>
        <p className="text-xs text-text-caption mt-1">
          {report.basisDescription} · {report.updatedDate} 갱신
        </p>
        <p className="text-body text-text-primary mt-3">{report.summary}</p>
        {report.latestTrendQuestionCount > 0 && (
          <p className="text-sm font-semibold text-brand mt-3">
            최신 경향 문제 {report.latestTrendQuestionCount}개를 풀 수 있어요
          </p>
        )}
      </section>

      {/* 과목별 비중 */}
      <section className={s1.className}>
        <h2 className="text-sm text-text-secondary mb-2 px-1">과목별 비중</h2>
        <div className="bg-surface-card border border-border rounded-2xl divide-y divide-border">
          {report.subjectShares.map((subjectShare) => (
            <div key={subjectShare.subjectName} className="p-4 space-y-2">
              <div className="flex items-center justify-between gap-2">
                <p className="text-sm font-semibold text-text-primary">{subjectShare.subjectName}</p>
                <p className="text-xs text-text-secondary tabular-nums">
                  {subjectShare.questionCount}문항 · {subjectShare.percent}%
                </p>
              </div>
              <ProgressBar
                fillPercent={subjectShare.percent}
                trackClassName="h-1.5 bg-border"
                fillClassName="bg-brand"
              />
              <p className="text-xs text-text-secondary">{subjectShare.description}</p>
            </div>
          ))}
        </div>
      </section>

      <TrendItemSection
        title="최근 회차에서 늘어난 유형"
        items={patternItems}
        onSolve={startLatestTrendPractice}
        className={s1.className}
      />
      <TrendItemSection
        title={`자주 나오는 개념 TOP ${conceptItems.length}`}
        footnote="최근 4회(58·60·61·62회) 합산 출제 문항 수 기준"
        items={conceptItems}
        onSolve={startLatestTrendPractice}
        className={s2.className}
      />

      {/* 공부 팁 */}
      <section className={s2.className}>
        <h2 className="text-sm text-text-secondary mb-2 px-1">공부 팁</h2>
        <ul className="bg-surface-card border border-border rounded-2xl divide-y divide-border">
          {report.studyTips.map((studyTip) => (
            <li key={studyTip} className="p-4 flex gap-2">
              <Lightbulb size={16} className="text-semantic-warning shrink-0 mt-0.5" aria-hidden="true" />
              <p className="text-sm text-text-primary">{studyTip}</p>
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}

interface TrendItemSectionProps {
  readonly title: string;
  readonly footnote?: string;
  readonly items: readonly SolvableTrendItem[];
  readonly onSolve: (topicCode: string, topicName: string) => void;
  readonly className: string;
}

/** 유형·개념 목록: 제목 + 빈도 배지 + 설명 + (문제 있으면) 풀기 버튼 */
function TrendItemSection({ title, footnote, items, onSolve, className }: TrendItemSectionProps) {
  if (items.length === 0) return null;
  return (
    <section className={className}>
      <h2 className="text-sm text-text-secondary mb-2 px-1">{title}</h2>
      <ul className="bg-surface-card border border-border rounded-2xl divide-y divide-border">
        {items.map((item) => (
          <li key={item.key} className="p-4">
            <div className="flex items-start justify-between gap-2">
              <p className="text-sm font-semibold text-text-primary">{item.title}</p>
              <span className="badge badge-sm border-0 bg-surface-code text-text-secondary whitespace-nowrap">
                {item.caption}
              </span>
            </div>
            <p className="text-xs text-text-secondary mt-1">{item.description}</p>
            {item.topicName && item.latestTrendQuestionCount > 0 && (
              <button
                type="button"
                className="btn btn-sm btn-ghost text-brand px-0 mt-1 gap-1"
                onClick={() => onSolve(item.topicCode, item.topicName!)}
              >
                {item.topicName} 최신 경향 문제 {item.latestTrendQuestionCount}개 풀기
                <ChevronRight size={14} aria-hidden="true" />
              </button>
            )}
          </li>
        ))}
      </ul>
      {footnote && <p className="text-xs text-text-caption mt-2 px-1">{footnote}</p>}
    </section>
  );
}
