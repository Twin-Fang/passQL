import { CheckCircle2 } from "lucide-react";
import ErrorFallback from "../ErrorFallback";
import LockedPreview from "../pro/LockedPreview";
import { WrongNotesLockedSample } from "../pro/lockedPreviewSamples";
import WrongQuestionRow from "./WrongQuestionRow";
import { LOCKED_PREVIEW_CAPTIONS } from "../../constants/proAccessCopy";
import { toProAccessErrorCode } from "../../lib/proAccess";
import type { WrongQuestionItem } from "../../types/api";

interface WrongQuestionListStateProps {
  readonly isLoading: boolean;
  readonly error: unknown;
  readonly items: readonly WrongQuestionItem[];
  readonly skeletonRowCount: number;
  // 카드 안에 그리는지 (true: 잠금·오류에 안쪽 여백, false: 화면에 바로 그림)
  readonly isInsideCard: boolean;
  readonly onRetry: () => void;
}

/**
 * 오답 목록 상태 공통 (마이페이지 미리보기·오답 노트 화면): 로딩 > 잠금 > 오류 > 빈 목록 > 목록
 * 무료(결제 켜짐) 403 PRO_REQUIRED 는 오류 대신 잠금 미리보기 (#578)
 */
export default function WrongQuestionListState({
  isLoading,
  error,
  items,
  skeletonRowCount,
  isInsideCard,
  onRetry,
}: WrongQuestionListStateProps) {
  if (isLoading) {
    return (
      <ul aria-busy="true" aria-label="오답 불러오는 중" className="divide-y divide-border">
        {Array.from({ length: skeletonRowCount }, (_, index) => (
          <li key={index} className="flex items-center gap-3 px-4 py-3">
            <div className="w-9 h-9 rounded-tile bg-border animate-pulse" />
            <div className="flex-1 space-y-1.5">
              <div className="h-3.5 bg-border rounded animate-pulse w-3/4" />
              <div className="h-3 bg-border rounded animate-pulse w-1/3" />
            </div>
            <div className="w-16 h-7 bg-border rounded animate-pulse" />
          </li>
        ))}
      </ul>
    );
  }

  if (error) {
    if (toProAccessErrorCode(error) === "PRO_REQUIRED") {
      return (
        <div className={isInsideCard ? "p-4" : ""}>
          <LockedPreview preview={<WrongNotesLockedSample />} caption={LOCKED_PREVIEW_CAPTIONS.wrongNotes} />
        </div>
      );
    }
    return (
      <div className={isInsideCard ? "px-4" : ""}>
        <ErrorFallback onRetry={onRetry} />
      </div>
    );
  }

  if (items.length === 0) {
    return (
      <div className="flex flex-col items-center text-center gap-2 py-12 px-4">
        <CheckCircle2 size={28} className="text-text-caption" aria-hidden="true" />
        <p className="text-sm text-text-secondary">아직 틀린 문제가 없어요</p>
        <p className="text-xs text-text-caption">문제를 풀면 오답이 여기에 쌓여요</p>
      </div>
    );
  }

  return (
    <ul className="divide-y divide-border">
      {items.map((item) => (
        <WrongQuestionRow key={item.questionUuid} item={item} />
      ))}
    </ul>
  );
}
