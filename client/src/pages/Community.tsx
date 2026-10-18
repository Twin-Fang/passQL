import { useState } from "react";
import { Link } from "react-router-dom";
import { UserRound } from "lucide-react";
import { useCommunityFeed } from "../hooks/useCommunity";
import CommunityFeedCardItem from "../components/community/CommunityFeedCardItem";
import CommunityListState from "../components/community/CommunityListState";
import CommunityLoadMoreButton from "../components/community/CommunityLoadMoreButton";
import { COMMUNITY_FEED_TABS, COMMUNITY_MINE_PATH, COMMUNITY_UGC_NOTICE } from "../lib/communityPresentation";
import type { CommunityFeedSource } from "../api/community";

/** 토론 피드: 뜨는 토론 | 최신 경향 | 내가 푼 문제 | 내 의견 (#525) */
export default function Community() {
  const [selectedSource, setSelectedSource] = useState<CommunityFeedSource>("hot");
  const feed = useCommunityFeed(selectedSource);
  const selectedTab = COMMUNITY_FEED_TABS.find((tab) => tab.source === selectedSource) ?? COMMUNITY_FEED_TABS[0];
  const cards = feed.data?.pages.flatMap((page) => page.items) ?? [];

  return (
    <div className="pt-4 lg:pt-0">
      <div className="flex items-center justify-between mb-1">
        <h1 className="text-h2 text-text-primary">토론</h1>
        <Link to={COMMUNITY_MINE_PATH} className="inline-flex items-center gap-1 text-sm font-semibold text-brand">
          <UserRound size={14} aria-hidden="true" />
          내 활동
        </Link>
      </div>
      <p className="text-xs text-text-caption mb-4">{COMMUNITY_UGC_NOTICE}</p>

      {/* 탭 4개: 모바일 폭에서도 줄바꿈 없이 가로 스크롤 */}
      <div role="tablist" className="tabs tabs-box mb-4 overflow-x-auto flex-nowrap">
        {COMMUNITY_FEED_TABS.map((tab) => (
          <button
            key={tab.source}
            type="button"
            role="tab"
            aria-selected={tab.source === selectedSource}
            onClick={() => setSelectedSource(tab.source)}
            className={`tab flex-1 whitespace-nowrap px-2 text-xs sm:text-sm ${tab.source === selectedSource ? "tab-active" : ""}`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div className="bg-surface-card border border-border rounded-2xl overflow-hidden">
        <CommunityListState
          isLoading={feed.isLoading}
          isError={feed.isError}
          isEmpty={cards.length === 0}
          emptyMessage={selectedTab.emptyMessage}
          emptyAction={
            <Link to={selectedTab.emptyActionPath} className="btn btn-primary btn-sm">
              {selectedTab.emptyActionLabel}
            </Link>
          }
          onRetry={() => void feed.refetch()}
        >
          <ul className="divide-y divide-border">
            {cards.map((card) => (
              <CommunityFeedCardItem key={card.questionUuid} card={card} />
            ))}
          </ul>
          <CommunityLoadMoreButton
            hasNextPage={feed.hasNextPage}
            isFetchingNextPage={feed.isFetchingNextPage}
            onLoadMore={() => void feed.fetchNextPage()}
          />
        </CommunityListState>
      </div>
    </div>
  );
}
