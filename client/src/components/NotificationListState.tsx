import type { ReactNode } from "react";
import { BellOff } from "lucide-react";
import ErrorFallback from "./ErrorFallback";

interface NotificationListStateProps {
  readonly isLoading: boolean;
  readonly isError: boolean;
  readonly isEmpty: boolean;
  readonly emptyMessage: string;
  readonly onRetry: () => void;
  readonly children: ReactNode;
}

/** 알림 목록 공통 상태: 로딩 > 오류 > 빈 목록 > 목록 (드롭다운·알림함 공용) */
export default function NotificationListState({
  isLoading,
  isError,
  isEmpty,
  emptyMessage,
  onRetry,
  children,
}: NotificationListStateProps) {
  if (isLoading) {
    return (
      <div className="flex justify-center py-10" role="status" aria-label="알림 불러오는 중">
        <span className="loading loading-spinner loading-md text-brand" />
      </div>
    );
  }
  if (isError) return <ErrorFallback onRetry={onRetry} />;
  if (isEmpty) {
    return (
      <div className="flex flex-col items-center gap-2 py-10 text-text-caption">
        <BellOff size={28} />
        <p className="text-sm">{emptyMessage}</p>
      </div>
    );
  }
  return <>{children}</>;
}
