import { Sparkles } from "lucide-react";
import { useExplanationHistoryStore } from "../../stores/explanationHistoryStore";

/**
 * 풀이 상단 바의 해설함 다시 열기: 항목이 있고 패널이 닫혀 있을 때만
 */
export default function ExplanationHistoryButton() {
  const entryCount = useExplanationHistoryStore((state) => state.entries.length);
  const isPanelOpen = useExplanationHistoryStore((state) => state.isOpen);
  const openHistory = useExplanationHistoryStore((state) => state.openHistory);

  if (entryCount === 0 || isPanelOpen) return null;
  return (
    <button
      type="button"
      aria-label={`해설함 열기 (${entryCount}개)`}
      className="btn btn-xs btn-ghost gap-1 rounded-full text-brand"
      onClick={openHistory}
    >
      <Sparkles size={12} />
      해설함 {entryCount}
    </button>
  );
}
