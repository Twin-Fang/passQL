import { useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, Lock } from "lucide-react";
import {
  useBlockCommunityAuthor,
  useCommunityPosts,
  useDeleteCommunityPost,
  useToggleCommunityPostLike,
} from "../hooks/useCommunity";
import CommunityListState from "../components/community/CommunityListState";
import CommunityLoadMoreButton from "../components/community/CommunityLoadMoreButton";
import CommunityPostComposer from "../components/community/CommunityPostComposer";
import CommunityQuestionCard from "../components/community/CommunityQuestionCard";
import CommunityPostItem from "../components/community/CommunityPostItem";
import CommunityReportModal from "../components/community/CommunityReportModal";
import ConfirmModal from "../components/ConfirmModal";
import { isSolveRequiredError, toCommunityErrorMessage } from "../lib/communityPresentation";
import type { CommunityPostSort } from "../api/community";

const SORT_TABS: readonly { readonly sort: CommunityPostSort; readonly label: string }[] = [
  { sort: "latest", label: "최신순" },
  { sort: "likes", label: "좋아요순" },
];

// 확인이 필요한 글 동작 (삭제 / 작성자 차단)
type PendingConfirm = { readonly kind: "delete" | "block"; readonly postUuid: string };

/** 문제별 의견: 정렬 + 작성 + 목록 + 글 메뉴, 풀이 전이면 잠금 안내 + 풀기 버튼 (#525) */
export default function CommunityQuestion() {
  const { questionUuid = "" } = useParams();
  const navigate = useNavigate();
  const [sort, setSort] = useState<CommunityPostSort>("latest");
  const [pendingConfirm, setPendingConfirm] = useState<PendingConfirm | null>(null);
  const [reportPostUuid, setReportPostUuid] = useState<string | null>(null);
  const [noticeMessage, setNoticeMessage] = useState<string | null>(null);

  const posts = useCommunityPosts(questionUuid, sort);
  const toggleLike = useToggleCommunityPostLike(questionUuid);
  const deletePost = useDeleteCommunityPost();
  const blockAuthor = useBlockCommunityAuthor();

  const items = posts.data?.pages.flatMap((page) => page.items) ?? [];
  const isSolveRequired = isSolveRequiredError(posts.error);

  const handleConfirm = () => {
    if (!pendingConfirm) return;
    const { kind, postUuid } = pendingConfirm;
    setPendingConfirm(null);
    const mutation = kind === "delete" ? deletePost : blockAuthor;
    mutation.mutate(postUuid, {
      onSuccess: () => setNoticeMessage(kind === "delete" ? "의견을 삭제했어요" : "작성자를 차단했어요"),
      onError: (error) => setNoticeMessage(toCommunityErrorMessage(error, "처리하지 못했어요. 잠시 후 다시 시도해 주세요")),
    });
  };

  return (
    <div className="pt-4 lg:pt-0 space-y-4">
      <div className="flex items-center gap-2">
        <button
          type="button"
          className="w-9 h-9 flex items-center justify-center text-text-secondary rounded-lg hover:bg-surface-card"
          onClick={() => navigate(-1)}
          aria-label="뒤로가기"
        >
          <ArrowLeft size={20} />
        </button>
        <h1 className="text-h2 text-text-primary">문제 의견</h1>
      </div>

      <CommunityQuestionCard questionUuid={questionUuid} />

      {isSolveRequired ? (
        <div className="bg-surface-card border border-border rounded-2xl py-10 px-6 flex flex-col items-center text-center gap-4">
          <div className="w-14 h-14 rounded-full bg-surface flex items-center justify-center">
            <Lock size={26} className="text-text-caption" aria-hidden="true" />
          </div>
          <p className="text-base font-semibold text-text-primary">풀고 나서 의견을 볼 수 있어요</p>
          <Link to={`/questions/${questionUuid}`} className="btn btn-primary">
            문제 풀기
          </Link>
        </div>
      ) : (
        <>
          <CommunityPostComposer questionUuid={questionUuid} />

          {noticeMessage && (
            <p role="status" className="text-xs text-text-secondary bg-surface-card border border-border rounded-xl px-3 py-2">
              {noticeMessage}
            </p>
          )}

          <div role="tablist" className="tabs tabs-box">
            {SORT_TABS.map((tab) => (
              <button
                key={tab.sort}
                type="button"
                role="tab"
                aria-selected={tab.sort === sort}
                onClick={() => setSort(tab.sort)}
                className={`tab flex-1 ${tab.sort === sort ? "tab-active" : ""}`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          <div className="bg-surface-card border border-border rounded-2xl overflow-hidden">
            <CommunityListState
              isLoading={posts.isLoading}
              isError={posts.isError}
              isEmpty={items.length === 0}
              emptyMessage="첫 의견을 남겨 보세요"
              onRetry={() => void posts.refetch()}
            >
              <ul className="divide-y divide-border">
                {items.map((post) => (
                  <CommunityPostItem
                    key={post.postUuid}
                    post={post}
                    isLikePending={toggleLike.isPending && toggleLike.variables === post.postUuid}
                    onLikeToggled={(postUuid) => toggleLike.mutate(postUuid)}
                    onDeleteRequested={(postUuid) => setPendingConfirm({ kind: "delete", postUuid })}
                    onReportRequested={setReportPostUuid}
                    onBlockRequested={(postUuid) => setPendingConfirm({ kind: "block", postUuid })}
                  />
                ))}
              </ul>
              <CommunityLoadMoreButton
                hasNextPage={posts.hasNextPage}
                isFetchingNextPage={posts.isFetchingNextPage}
                onLoadMore={() => void posts.fetchNextPage()}
              />
            </CommunityListState>
          </div>
        </>
      )}

      <ConfirmModal
        isOpen={pendingConfirm !== null}
        title={pendingConfirm?.kind === "delete" ? "의견을 삭제할까요?" : "작성자를 차단할까요?"}
        description={
          pendingConfirm?.kind === "delete"
            ? "삭제한 의견은 되돌릴 수 없어요"
            : "이 작성자의 의견이 더 이상 보이지 않아요. 내 활동에서 해제할 수 있어요"
        }
        confirmLabel={pendingConfirm?.kind === "delete" ? "삭제" : "차단"}
        cancelLabel="취소"
        onConfirm={handleConfirm}
        onCancel={() => setPendingConfirm(null)}
      />

      {reportPostUuid && (
        <CommunityReportModal
          postUuid={reportPostUuid}
          onClose={() => setReportPostUuid(null)}
          onReported={() => {
            setReportPostUuid(null);
            setNoticeMessage("신고가 접수됐어요");
          }}
        />
      )}
    </div>
  );
}
