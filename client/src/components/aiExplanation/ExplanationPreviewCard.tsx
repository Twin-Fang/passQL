import { ChevronRight, RotateCw, Sparkles } from "lucide-react";
import InlineMarkdownText from "./InlineMarkdownText";
import ExplanationSkeleton from "./ExplanationSkeleton";
import { useChoiceExplanation, type ChoiceExplanationView } from "../../hooks/useChoiceExplanation";
import { findSelectedChoiceAnalysis } from "../../lib/choiceExplanationPresentation";
import type { ExplanationHistoryEntry } from "../../stores/explanationHistoryStore";

// 마크다운 폴백 미리보기: 표기 기호 제거 후 첫 내용 (목록 기호·굵게 표시)
const MARKDOWN_SYMBOL_PATTERN = /^\s*[-*]\s+|\*\*/gm;

/** 마크다운 > 미리보기용 한 덩어리 글 */
function toPreviewText(markdownText: string): string {
  return markdownText.replace(MARKDOWN_SYMBOL_PATTERN, "").replace(/\s+/g, " ").trim();
}

/** 상태별 미리보기 본문: 판정 한 줄 + 정답 근거 2줄 / 기다림 / 실패 */
function PreviewBody({ explanationView }: { readonly explanationView: ChoiceExplanationView }) {
  if (explanationView.phase === "loading") return <ExplanationSkeleton lineCount={2} />;

  if (explanationView.phase === "failed" && !explanationView.markdownText) {
    return (
      <div className="flex items-center justify-between gap-2">
        <p role="alert" className="text-sm text-text-secondary">AI 해설을 불러오지 못했어요</p>
        <button
          type="button"
          className="btn btn-xs btn-ghost text-brand gap-1"
          onClick={(event) => {
            // 카드 전체 열기와 겹치지 않게
            event.stopPropagation();
            explanationView.retry();
          }}
        >
          <RotateCw size={12} />
          다시 시도
        </button>
      </div>
    );
  }

  const explanation = explanationView.explanation;
  if (explanation) {
    const selectedReason = findSelectedChoiceAnalysis(explanation)?.reason;
    return (
      <div className="space-y-1">
        {selectedReason && (
          <InlineMarkdownText
            text={selectedReason}
            className={`block text-sm font-semibold line-clamp-1 ${
              explanation.isSelectedCorrect ? "text-semantic-success-text" : "text-semantic-error-text"
            }`}
          />
        )}
        <InlineMarkdownText text={explanation.correctReason} className="block text-sm leading-relaxed text-text-primary line-clamp-2" />
      </div>
    );
  }
  return (
    <InlineMarkdownText
      text={toPreviewText(explanationView.markdownText ?? "")}
      className="block text-sm leading-relaxed text-text-primary line-clamp-2"
    />
  );
}

interface ExplanationPreviewCardProps {
  readonly entry: ExplanationHistoryEntry;
  readonly onOpen: () => void;
}

/**
 * 제출 직후 해설 미리보기: AI 해설 머리 > 판정·근거 요약 > 해설 전체 보기 (누르면 비모달 패널)
 */
export default function ExplanationPreviewCard({ entry, onOpen }: ExplanationPreviewCardProps) {
  const explanationView = useChoiceExplanation(entry);
  const canOpen = explanationView.phase !== "failed" || Boolean(explanationView.markdownText);

  return (
    // 카드 어디를 눌러도 열림 (키보드는 머리의 버튼으로)
    <div
      className="explanation-preview-card block w-full px-3.5 py-3 mb-3 text-left cursor-pointer transition-opacity hover:opacity-90"
      onClick={onOpen}
    >
      <div className="flex items-center gap-1.5 mb-1.5">
        <Sparkles size={13} className="text-brand shrink-0" />
        <span className="text-xs font-semibold text-brand flex-1">AI 해설</span>
        {canOpen && (
          <button
            type="button"
            className="flex items-center text-xs font-semibold text-text-secondary hover:text-text-primary"
            onClick={(event) => {
              event.stopPropagation();
              onOpen();
            }}
          >
            해설 전체 보기
            <ChevronRight size={14} />
          </button>
        )}
      </div>
      <PreviewBody explanationView={explanationView} />
    </div>
  );
}
