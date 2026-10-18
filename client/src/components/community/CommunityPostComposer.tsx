import { useState } from "react";
import { Send } from "lucide-react";
import {
  COMMUNITY_POST_MAX_LENGTH,
  COMMUNITY_UGC_NOTICE,
  toCommunityErrorMessage,
} from "../../lib/communityPresentation";
import { useCreateCommunityPost } from "../../hooks/useCommunity";

interface CommunityPostComposerProps {
  readonly questionUuid: string;
}

/** 의견 작성: 500자 카운터 + '내 풀이 같이 보여주기' 토글 + UGC 안내 */
export default function CommunityPostComposer({ questionUuid }: CommunityPostComposerProps) {
  const [content, setContent] = useState("");
  const [isSnapshotIncluded, setIsSnapshotIncluded] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const { mutate: createPost, isPending } = useCreateCommunityPost(questionUuid);

  const trimmedContent = content.trim();
  const canSubmit = trimmedContent.length > 0 && trimmedContent.length <= COMMUNITY_POST_MAX_LENGTH && !isPending;

  const handleSubmit = () => {
    if (!canSubmit) return;
    setErrorMessage(null);
    createPost(
      { content: trimmedContent, includeSolveSnapshot: isSnapshotIncluded },
      {
        onSuccess: () => setContent(""),
        onError: (error) => setErrorMessage(toCommunityErrorMessage(error, "의견을 남기지 못했어요. 잠시 후 다시 시도해 주세요")),
      },
    );
  };

  return (
    <section className="bg-surface-card border border-border rounded-2xl p-4 space-y-3" aria-label="의견 작성">
      <textarea
        className="textarea w-full min-h-24 resize-none bg-surface text-sm"
        placeholder="헷갈렸던 점이나 풀이 팁을 남겨 보세요"
        maxLength={COMMUNITY_POST_MAX_LENGTH}
        value={content}
        onChange={(event) => setContent(event.target.value)}
        disabled={isPending}
        aria-label="의견 내용"
      />
      <div className="flex items-center justify-between gap-3">
        <label className="flex items-center gap-2 text-xs text-text-secondary cursor-pointer min-w-0">
          <input
            type="checkbox"
            className="toggle toggle-sm toggle-primary shrink-0"
            checked={isSnapshotIncluded}
            onChange={(event) => setIsSnapshotIncluded(event.target.checked)}
            disabled={isPending}
          />
          <span className="truncate">내 풀이 같이 보여주기</span>
        </label>
        <span className="shrink-0 text-xs text-text-caption tabular-nums">
          {content.length}/{COMMUNITY_POST_MAX_LENGTH}
        </span>
      </div>
      {errorMessage && <p role="alert" className="text-xs text-semantic-error-text">{errorMessage}</p>}
      <div className="flex items-center justify-between gap-3">
        <p className="text-caption2 text-text-caption">{COMMUNITY_UGC_NOTICE}</p>
        <button type="button" className="btn btn-primary btn-sm shrink-0" onClick={handleSubmit} disabled={!canSubmit}>
          {isPending ? <span className="loading loading-spinner loading-xs" /> : <Send size={14} aria-hidden="true" />}
          남기기
        </button>
      </div>
    </section>
  );
}
