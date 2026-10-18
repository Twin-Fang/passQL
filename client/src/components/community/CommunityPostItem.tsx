import { useState } from "react";
import { Ban, Flag, Heart, MoreHorizontal, Trash2 } from "lucide-react";
import CommunityPostImages from "./CommunityPostImages";
import { toSolveSnapshotLabel } from "../../lib/communityPresentation";
import { formatNotificationTime } from "../../lib/notificationPresentation";
import type { CommunityPost } from "../../types/api";

interface CommunityPostItemProps {
  readonly post: CommunityPost;
  readonly isLikePending: boolean;
  readonly onLikeToggled: (postUuid: string) => void;
  readonly onDeleteRequested: (postUuid: string) => void;
  readonly onReportRequested: (postUuid: string) => void;
  readonly onBlockRequested: (postUuid: string) => void;
}

/** 의견 한 건: 닉네임 + 풀이 스냅샷 배지 + 내용 + 좋아요 + 글 메뉴(본인 삭제 / 타인 신고·차단) */
export default function CommunityPostItem({
  post,
  isLikePending,
  onLikeToggled,
  onDeleteRequested,
  onReportRequested,
  onBlockRequested,
}: CommunityPostItemProps) {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  // 메뉴 항목 선택 > 닫기 + 동작
  const selectMenuItem = (action: (postUuid: string) => void) => () => {
    setIsMenuOpen(false);
    action(post.postUuid);
  };

  return (
    <li className="px-4 py-3.5 space-y-2">
      <div className="flex items-center gap-2">
        <span className="text-sm font-semibold text-text-primary truncate">{post.authorNickname}</span>
        {post.isMine && <span className="text-micro font-bold text-brand bg-brand-light rounded px-1.5 py-0.5">내 글</span>}
        <span className="text-xs text-text-caption shrink-0">{formatNotificationTime(post.createdAt)}</span>
        <div className="relative ml-auto">
          <button
            type="button"
            className="w-8 h-8 flex items-center justify-center rounded-lg text-text-caption hover:bg-surface"
            aria-label="의견 메뉴"
            aria-expanded={isMenuOpen}
            onClick={() => setIsMenuOpen((isOpen) => !isOpen)}
          >
            <MoreHorizontal size={18} />
          </button>
          {isMenuOpen && (
            <>
              {/* 바깥 클릭으로 닫기 */}
              <button type="button" className="fixed inset-0 z-10 cursor-default" aria-label="메뉴 닫기" onClick={() => setIsMenuOpen(false)} />
              <ul className="absolute right-0 top-9 z-20 w-40 bg-surface-card border border-border rounded-xl py-1 shadow-lg">
                {post.isMine ? (
                  <MenuItem icon={<Trash2 size={14} />} label="삭제" onSelected={selectMenuItem(onDeleteRequested)} />
                ) : (
                  <>
                    <MenuItem icon={<Flag size={14} />} label="신고" onSelected={selectMenuItem(onReportRequested)} />
                    <MenuItem icon={<Ban size={14} />} label="작성자 차단" onSelected={selectMenuItem(onBlockRequested)} />
                  </>
                )}
              </ul>
            </>
          )}
        </div>
      </div>

      {post.solveSnapshot && (
        <span className="inline-block text-xs font-semibold text-brand bg-brand-light rounded-full px-2.5 py-1">
          {toSolveSnapshotLabel(post.solveSnapshot)}
        </span>
      )}

      <p className="text-sm text-text-primary whitespace-pre-wrap break-words">{post.content}</p>

      <CommunityPostImages images={post.images} />

      <button
        type="button"
        className={`inline-flex items-center gap-1.5 text-xs font-medium ${post.isLikedByMe ? "text-brand" : "text-text-caption"} disabled:opacity-60`}
        aria-pressed={post.isLikedByMe}
        aria-label="좋아요"
        disabled={isLikePending}
        onClick={() => onLikeToggled(post.postUuid)}
      >
        <Heart size={14} fill={post.isLikedByMe ? "currentColor" : "none"} aria-hidden="true" />
        {post.likeCount}
      </button>
    </li>
  );
}

function MenuItem({ icon, label, onSelected }: { readonly icon: React.ReactNode; readonly label: string; readonly onSelected: () => void }) {
  return (
    <li>
      <button
        type="button"
        className="w-full flex items-center gap-2 px-3 py-2 text-sm text-text-primary hover:bg-surface"
        onClick={onSelected}
      >
        {icon}
        {label}
      </button>
    </li>
  );
}
