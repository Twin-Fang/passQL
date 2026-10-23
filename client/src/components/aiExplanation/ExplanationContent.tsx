import type { ReactNode } from "react";
import { AlertTriangle, BookOpen, Check, Lightbulb, ListChecks, Target, X } from "lucide-react";
import InlineMarkdownText from "./InlineMarkdownText";
import ExplanationLockedPreview from "./ExplanationLockedPreview";
import {
  composeVerdict,
  sortChoiceAnalysesByDisplayOrder,
  toDisplayLabel,
  type DisplayLabelByChoiceKey,
} from "../../lib/choiceExplanationPresentation";
import type { ChoiceAnalysis, ChoiceExplanation } from "../../types/api";

interface ExplanationSectionProps {
  readonly title: string;
  readonly icon: ReactNode;
  readonly toneClassName?: string;
  readonly titleClassName?: string;
  readonly children: ReactNode;
}

/** 섹션 카드 한 장: 아이콘 머리 + 본문 */
function ExplanationSection({ title, icon, toneClassName = "", titleClassName = "text-text-secondary", children }: ExplanationSectionProps) {
  return (
    <section className={`explanation-section ${toneClassName}`}>
      <h3 className={`flex items-center gap-1.5 text-xs font-semibold mb-2 ${titleClassName}`}>
        {icon}
        {title}
      </h3>
      {children}
    </section>
  );
}

interface ChoiceAnalysisRowProps {
  readonly analysis: ChoiceAnalysis;
  readonly displayLabel: string;
  readonly isSelected: boolean;
}

/** 보기 1개 판단: 표시 라벨 원 + 정답·내 선택 태그 + 이유 */
function ChoiceAnalysisRow({ analysis, displayLabel, isSelected }: ChoiceAnalysisRowProps) {
  const labelToneClass = analysis.isCorrect
    ? "bg-semantic-success text-on-brand"
    : isSelected
      ? "bg-semantic-error text-on-brand"
      : "bg-surface-code text-text-secondary";
  return (
    <li className={`flex gap-2.5 py-2 ${isSelected || analysis.isCorrect ? "" : "opacity-80"}`}>
      <span
        className={`w-6 h-6 shrink-0 rounded-full flex items-center justify-center text-xs font-bold ${labelToneClass}`}
        aria-label={`보기 ${displayLabel}`}
      >
        {displayLabel}
      </span>
      <div className="min-w-0 flex-1">
        <div className="flex flex-wrap gap-1 mb-0.5">
          {analysis.isCorrect && (
            <span className="badge badge-sm border-0 bg-semantic-success-light text-semantic-success-text font-semibold">정답</span>
          )}
          {isSelected && (
            <span
              className={`badge badge-sm border-0 font-semibold ${
                analysis.isCorrect ? "bg-brand-light text-brand" : "bg-semantic-error-light text-semantic-error-text"
              }`}
            >
              내 선택
            </span>
          )}
        </div>
        <InlineMarkdownText text={analysis.reason} className="text-sm leading-relaxed text-text-primary" />
      </div>
    </li>
  );
}

interface ExplanationContentProps {
  readonly explanation: ChoiceExplanation;
  readonly displayLabelByChoiceKey: DisplayLabelByChoiceKey;
  // 무료(결제 켜짐): 서버가 판정 외 섹션을 비워 보냄 > 판정 아래 잠금 미리보기 (#578)
  readonly isFullExplanationLocked?: boolean;
}

/**
 * 구조화 해설 전체: 판정 배지 > 정답 근거 > 핵심 개념 > 헷갈리는 지점 > 보기별 판단 > 시험 팁 > AI 안내
 */
export default function ExplanationContent({
  explanation,
  displayLabelByChoiceKey,
  isFullExplanationLocked = false,
}: ExplanationContentProps) {
  const isCorrect = explanation.isSelectedCorrect;
  const correctLabel = toDisplayLabel(displayLabelByChoiceKey, explanation.correctChoiceKey);
  const sortedAnalyses = sortChoiceAnalysesByDisplayOrder(explanation.choiceAnalyses, displayLabelByChoiceKey);

  return (
    <div className="space-y-3">
      {/* 판정: 정답/오답 색 + 표시 라벨로 조립한 한 줄 */}
      <div
        className={`flex items-start gap-2 rounded-xl px-3.5 py-3 ${
          isCorrect ? "bg-semantic-success-light" : "bg-semantic-error-light"
        }`}
      >
        <span
          className={`w-6 h-6 shrink-0 rounded-full flex items-center justify-center ${
            isCorrect ? "bg-semantic-success" : "bg-semantic-error"
          }`}
        >
          {isCorrect ? <Check size={14} className="text-on-brand" /> : <X size={14} className="text-on-brand" />}
        </span>
        <InlineMarkdownText
          text={composeVerdict(explanation, displayLabelByChoiceKey)}
          className={`text-sm font-semibold leading-relaxed ${
            isCorrect ? "text-semantic-success-text" : "text-semantic-error-text"
          }`}
        />
      </div>

      {isFullExplanationLocked && <ExplanationLockedPreview />}

      {explanation.correctReason.trim() && (
        <ExplanationSection title={`정답 ${correctLabel} 근거`} icon={<Target size={13} />}>
          <InlineMarkdownText text={explanation.correctReason} className="text-sm leading-relaxed text-text-primary" />
        </ExplanationSection>
      )}

      {/* 시험 팁: 정답 근거 바로 아래 (앱 AiExplanationSections 와 같은 순서) */}
      {explanation.examTip && (
        <ExplanationSection
          title="시험 팁"
          icon={<Lightbulb size={13} />}
          toneClassName="explanation-section--tip"
          titleClassName="text-brand"
        >
          <InlineMarkdownText text={explanation.examTip} className="text-sm leading-relaxed text-text-primary" />
        </ExplanationSection>
      )}

      {explanation.keyConcepts.length > 0 && (
        <ExplanationSection title="핵심 개념" icon={<BookOpen size={13} />}>
          <dl className="space-y-2.5">
            {explanation.keyConcepts.map((concept) => (
              <div key={concept.name}>
                <dt className="inline-flex mb-1 rounded-md bg-brand-light px-2 py-0.5 text-xs font-semibold font-mono text-brand">
                  {concept.name}
                </dt>
                <dd>
                  <InlineMarkdownText text={concept.description} className="text-sm leading-relaxed text-text-primary" />
                </dd>
              </div>
            ))}
          </dl>
        </ExplanationSection>
      )}

      {explanation.confusingPoints.length > 0 && (
        <ExplanationSection
          title="헷갈리는 지점"
          icon={<AlertTriangle size={13} />}
          toneClassName="explanation-section--warning"
          titleClassName="text-semantic-warning-text"
        >
          <ul className="list-disc pl-4 space-y-1">
            {explanation.confusingPoints.map((point) => (
              <li key={point} className="text-sm leading-relaxed text-text-primary">
                <InlineMarkdownText text={point} />
              </li>
            ))}
          </ul>
        </ExplanationSection>
      )}

      {sortedAnalyses.length > 0 && (
        <ExplanationSection title="보기별 판단" icon={<ListChecks size={13} />}>
          <ul className="divide-y divide-border">
            {sortedAnalyses.map((analysis) => (
              <ChoiceAnalysisRow
                key={analysis.choiceKey}
                analysis={analysis}
                displayLabel={toDisplayLabel(displayLabelByChoiceKey, analysis.choiceKey)}
                isSelected={analysis.choiceKey === explanation.selectedChoiceKey}
              />
            ))}
          </ul>
        </ExplanationSection>
      )}

      {/* 모델·프롬프트 버전은 서버 설정이 바뀌면 틀려지므로 고정 문구로 적지 않는다 */}
      <p className="text-caption1 text-text-caption text-right">AI가 만든 해설이에요. 참고용으로 봐 주세요.</p>
    </div>
  );
}
