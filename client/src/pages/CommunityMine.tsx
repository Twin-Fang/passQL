import { Link, useNavigate } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import { useBlockedMembers, useCommunityFeed, useUnblockMember } from "../hooks/useCommunity";
import CommunityFeedCardItem from "../components/community/CommunityFeedCardItem";
import CommunityListState from "../components/community/CommunityListState";
import CommunityLoadMoreButton from "../components/community/CommunityLoadMoreButton";
import { formatNotificationTime } from "../lib/notificationPresentation";

/** 내 활동: 내가 의견을 남긴 문제 + 차단 관리 (#525) */
export default function CommunityMine() {
  const navigate = useNavigate();
  const myFeed = useCommunityFeed("mine");
  const blockedMembers = useBlockedMembers();
  const { mutate: unblock, isPending: isUnblocking } = useUnblockMember();
  const cards = myFeed.data?.pages.flatMap((page) => page.items) ?? [];

  return (
    <div className="pt-4 lg:pt-0 space-y-6">
      <div className="flex items-center gap-2">
        <button
          type="button"
          className="w-9 h-9 flex items-center justify-center text-text-secondary rounded-lg hover:bg-surface-card"
          onClick={() => navigate(-1)}
          aria-label="뒤로가기"
        >
          <ArrowLeft size={20} />
        </button>
        <h1 className="text-h2 text-text-primary">내 활동</h1>
      </div>

      <section className="space-y-2">
        <h2 className="text-sm font-semibold text-text-primary">내 의견</h2>
        <div className="bg-surface-card border border-border rounded-2xl overflow-hidden">
          <CommunityListState
            isLoading={myFeed.isLoading}
            isError={myFeed.isError}
            isEmpty={cards.length === 0}
            emptyMessage="아직 남긴 의견이 없어요"
            emptyAction={
              <Link to="/questions" className="btn btn-primary btn-sm">
                문제 풀러 가기
              </Link>
            }
            onRetry={() => void myFeed.refetch()}
          >
            <ul className="divide-y divide-border">
              {cards.map((card) => (
                <CommunityFeedCardItem key={card.questionUuid} card={card} />
              ))}
            </ul>
            <CommunityLoadMoreButton
              hasNextPage={myFeed.hasNextPage}
              isFetchingNextPage={myFeed.isFetchingNextPage}
              onLoadMore={() => void myFeed.fetchNextPage()}
            />
          </CommunityListState>
        </div>
      </section>

      <section className="space-y-2">
        <h2 className="text-sm font-semibold text-text-primary">차단 관리</h2>
        <div className="bg-surface-card border border-border rounded-2xl overflow-hidden">
          <CommunityListState
            isLoading={blockedMembers.isLoading}
            isError={blockedMembers.isError}
            isEmpty={(blockedMembers.data ?? []).length === 0}
            emptyMessage="차단한 작성자가 없어요"
            onRetry={() => void blockedMembers.refetch()}
          >
            <ul className="divide-y divide-border">
              {(blockedMembers.data ?? []).map((blocked) => (
                <li key={blocked.blockUuid} className="flex items-center gap-3 px-4 py-3">
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-text-primary truncate">{blocked.nickname}</p>
                    <p className="text-xs text-text-caption">{formatNotificationTime(blocked.blockedAt)} 차단</p>
                  </div>
                  <button
                    type="button"
                    className="btn btn-outline btn-sm shrink-0"
                    onClick={() => unblock(blocked.blockUuid)}
                    disabled={isUnblocking}
                  >
                    차단 해제
                  </button>
                </li>
              ))}
            </ul>
          </CommunityListState>
        </div>
      </section>
    </div>
  );
}
