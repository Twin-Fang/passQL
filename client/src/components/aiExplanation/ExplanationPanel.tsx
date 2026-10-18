import { useEffect } from "react";
import { ArrowLeft, ChevronDown, ChevronUp, History, Sparkles, X } from "lucide-react";
import ExplanationBody from "./ExplanationBody";
import ExplanationHistoryList from "./ExplanationHistoryList";
import { useChoiceExplanation } from "../../hooks/useChoiceExplanation";
import { useExplanationHistoryStore, type ExplanationHistoryEntry } from "../../stores/explanationHistoryStore";

/** 화면에 안 보이는 해설도 관찰 유지 > 다음 문제로 넘어가도 백그라운드로 완료 */
function ExplanationBackgroundObserver({ entry }: { readonly entry: ExplanationHistoryEntry }) {
  useChoiceExplanation(entry);
  return null;
}

/**
 * 비모달 AI 해설 패널 (풀이 화면 공통, 오버레이 없음)
 * 좁은 화면: 하단 바 바로 위 시트 (접힘 = 머리 한 줄, 펼침 = 해설) / xl 이상: 오른쪽 사이드 패널
 * 머리: 제목 > 해설함 > 접기·펼치기 > 닫기. 풀이 페이지를 벗어나면 해설함 초기화
 */
export default function ExplanationPanel() {
  const entries = useExplanationHistoryStore((state) => state.entries);
  const activeEntryId = useExplanationHistoryStore((state) => state.activeEntryId);
  const isOpen = useExplanationHistoryStore((state) => state.isOpen);
  const isExpanded = useExplanationHistoryStore((state) => state.isExpanded);
  const view = useExplanationHistoryStore((state) => state.view);
  const openEntry = useExplanationHistoryStore((state) => state.openEntry);
  const openHistory = useExplanationHistoryStore((state) => state.openHistory);
  const toggleExpanded = useExplanationHistoryStore((state) => state.toggleExpanded);
  const close = useExplanationHistoryStore((state) => state.close);
  const reset = useExplanationHistoryStore((state) => state.reset);

  // 세션 범위: 진입·이탈 시 비움 (다른 풀이의 해설이 섞이지 않게)
  useEffect(() => {
    reset();
    return reset;
  }, [reset]);

  const activeEntry = entries.find((entry) => entry.id === activeEntryId) ?? null;
  const isHistoryView = view === "history" || !activeEntry;
  const title = isHistoryView ? "해설함" : `AI 해설 · ${activeEntry.questionLabel}`;

  return (
    <>
      {entries.map((entry) => (
        <ExplanationBackgroundObserver key={entry.id} entry={entry} />
      ))}
      {isOpen && (
        <aside className="explanation-panel" aria-label="AI 해설 패널">
          <header className="flex items-center gap-1 px-2 py-2 border-b border-border">
            <span className="w-8 h-8 flex items-center justify-center">
              {isHistoryView ? <History size={16} className="text-brand" /> : <Sparkles size={16} className="text-brand" />}
            </span>
            <button
              type="button"
              className="flex-1 min-w-0 text-left text-sm font-bold text-text-primary truncate xl:cursor-default"
              aria-expanded={isExpanded}
              onClick={toggleExpanded}
            >
              {title}
            </button>
            {!isHistoryView && (
              <button
                type="button"
                className="btn btn-xs btn-ghost gap-1 text-text-secondary"
                aria-label={`해설함 (${entries.length}개)`}
                onClick={openHistory}
              >
                <History size={14} />
                {entries.length}
              </button>
            )}
            {isHistoryView && activeEntry && (
              <button
                type="button"
                className="btn btn-xs btn-ghost btn-square text-text-secondary"
                aria-label="보던 해설로"
                onClick={() => openEntry(activeEntry.id)}
              >
                <ArrowLeft size={14} />
              </button>
            )}
            {/* 접기·펼치기: 좁은 화면 시트만 */}
            <button
              type="button"
              className="btn btn-xs btn-ghost btn-square text-text-secondary xl:hidden"
              aria-label={isExpanded ? "해설 접기" : "해설 펼치기"}
              onClick={toggleExpanded}
            >
              {isExpanded ? <ChevronDown size={16} /> : <ChevronUp size={16} />}
            </button>
            <button
              type="button"
              className="btn btn-xs btn-ghost btn-square text-text-secondary"
              aria-label="해설 닫기"
              onClick={close}
            >
              <X size={16} />
            </button>
          </header>
          {/* 접힘: 좁은 화면에서 본문 숨김 (넓은 화면은 항상 보임) */}
          <div className={`explanation-panel-body ${isExpanded ? "" : "hidden xl:block"}`}>
            {isHistoryView ? (
              <ExplanationHistoryList entries={entries} activeEntryId={activeEntryId} onSelect={openEntry} />
            ) : (
              <div className="px-4 py-4">
                <ExplanationBody key={activeEntry.id} entry={activeEntry} />
              </div>
            )}
          </div>
        </aside>
      )}
    </>
  );
}
