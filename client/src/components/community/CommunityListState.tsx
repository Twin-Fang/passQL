import type { ReactNode } from "react";
import { MessageSquareOff } from "lucide-react";
import ErrorFallback from "../ErrorFallback";

interface CommunityListStateProps {
  readonly isLoading: boolean;
  readonly isError: boolean;
  readonly isEmpty: boolean;
  readonly emptyMessage: string;
  /** 빈 상태 행동 유도 버튼 (선택) */
  readonly emptyAction?: ReactNode;
  readonly onRetry: () => void;
  readonly children: ReactNode;
}

/** 커뮤니티 목록 공통 상태: 로딩 > 오류 > 빈 목록 > 목록 (피드·의견·차단 목록 공용) */
export default function CommunityListState({
  isLoading,
  isError,
  isEmpty,
  emptyMessage,
  emptyAction,
  onRetry,
  children,
}: CommunityListStateProps) {
  if (isLoading) {
    return (
      <div className="flex justify-center py-10" role="status" aria-label="불러오는 중">
        <span className="loading loading-spinner loading-md text-brand" />
      </div>
    );
  }
  if (isError) return <ErrorFallback onRetry={onRetry} />;
  if (isEmpty) {
    return (
      <div className="flex flex-col items-center gap-3 py-10 text-text-caption">
        <MessageSquareOff size={28} aria-hidden="true" />
        <p className="text-sm">{emptyMessage}</p>
        {emptyAction}
      </div>
    );
  }
  return <>{children}</>;
}
