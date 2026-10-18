interface CommunityLoadMoreButtonProps {
  readonly hasNextPage: boolean;
  readonly isFetchingNextPage: boolean;
  readonly onLoadMore: () => void;
}

/** 커서 더 보기 버튼 (다음 페이지 없으면 숨김) */
export default function CommunityLoadMoreButton({ hasNextPage, isFetchingNextPage, onLoadMore }: CommunityLoadMoreButtonProps) {
  if (!hasNextPage) return null;
  return (
    <div className="p-3 border-t border-border">
      <button type="button" className="btn btn-ghost btn-sm w-full" onClick={onLoadMore} disabled={isFetchingNextPage}>
        {isFetchingNextPage ? <span className="loading loading-spinner loading-xs" /> : "더 보기"}
      </button>
    </div>
  );
}
