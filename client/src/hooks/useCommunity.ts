import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import type { InfiniteData } from "@tanstack/react-query";
import {
  blockCommunityPostAuthor,
  createCommunityPost,
  deleteCommunityPost,
  fetchBlockedMembers,
  fetchCommunityFeed,
  fetchCommunityPosts,
  reportCommunityPost,
  toggleCommunityPostLike,
  unblockMember,
} from "../api/community";
import type { CommunityFeedSource, CommunityPostSort } from "../api/community";
import { isSolveRequiredError } from "../lib/communityPresentation";
import { useMemberQueryScope } from "./useMemberQueryScope";
import type { CommunityPostCreatePayload, CommunityPostLike, CommunityPostPage, CommunityReportPayload } from "../types/api";

// 회원별 캐시 키 (#516: 로그아웃·탈퇴 때 clearMemberSession 이 queryClient 를 비움)
const communityKey = (memberUuid: string | null) => ["community", memberUuid] as const;

const COMMUNITY_FEED_STALE_MILLISECONDS = 1000 * 30;

/** 탭별 피드 (커서 더 보기) */
export function useCommunityFeed(source: CommunityFeedSource) {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useInfiniteQuery({
    queryKey: [...communityKey(memberUuid), "feed", source],
    queryFn: ({ pageParam }) => fetchCommunityFeed(source, pageParam),
    initialPageParam: null as string | null,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
    enabled: isMemberQueryEnabled,
    staleTime: COMMUNITY_FEED_STALE_MILLISECONDS,
    retry: false,
  });
}

/** 홈 '오늘의 토론': HOT 1위 카드 (없거나 실패면 null) */
export function useTodayDiscussion() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: [...communityKey(memberUuid), "today"],
    queryFn: async () => (await fetchCommunityFeed("hot", null)).items[0] ?? null,
    enabled: isMemberQueryEnabled,
    staleTime: COMMUNITY_FEED_STALE_MILLISECONDS * 10,
    retry: false,
  });
}

/** 문제별 의견 목록 (풀이 전 400 은 재시도하지 않고 호출부가 안내) */
export function useCommunityPosts(questionUuid: string, sort: CommunityPostSort) {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useInfiniteQuery({
    queryKey: [...communityKey(memberUuid), "posts", questionUuid, sort],
    queryFn: ({ pageParam }) => fetchCommunityPosts(questionUuid, sort, pageParam),
    initialPageParam: null as string | null,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
    enabled: isMemberQueryEnabled && questionUuid !== "",
    retry: (failureCount, error) => !isSolveRequiredError(error) && failureCount < 1,
  });
}

/** 의견 작성·삭제·신고·차단 후 피드와 목록 전체 갱신 */
function useInvalidateCommunity() {
  const queryClient = useQueryClient();
  const { memberUuid } = useMemberQueryScope();
  return () => queryClient.invalidateQueries({ queryKey: communityKey(memberUuid) });
}

export function useCreateCommunityPost(questionUuid: string) {
  const invalidateCommunity = useInvalidateCommunity();
  return useMutation({
    mutationFn: (payload: CommunityPostCreatePayload) => createCommunityPost(questionUuid, payload),
    onSuccess: invalidateCommunity,
  });
}

export function useDeleteCommunityPost() {
  const invalidateCommunity = useInvalidateCommunity();
  return useMutation({ mutationFn: deleteCommunityPost, onSuccess: invalidateCommunity });
}

export function useReportCommunityPost() {
  return useMutation({
    mutationFn: ({ postUuid, payload }: { readonly postUuid: string; readonly payload: CommunityReportPayload }) =>
      reportCommunityPost(postUuid, payload),
  });
}

/** 작성자 차단: 그 회원 글이 모든 목록에서 빠지므로 커뮤니티·차단 목록 갱신 */
export function useBlockCommunityAuthor() {
  const invalidateCommunity = useInvalidateCommunity();
  const queryClient = useQueryClient();
  const { memberUuid } = useMemberQueryScope();
  return useMutation({
    mutationFn: blockCommunityPostAuthor,
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: [...communityKey(memberUuid), "blocks"] });
      return invalidateCommunity();
    },
  });
}

/** 좋아요 토글: 서버 응답(isLiked, likeCount)을 캐시 목록에 바로 반영 */
export function useToggleCommunityPostLike(questionUuid: string) {
  const queryClient = useQueryClient();
  const { memberUuid } = useMemberQueryScope();
  return useMutation({
    mutationFn: toggleCommunityPostLike,
    onSuccess: (like: CommunityPostLike, postUuid) => {
      queryClient.setQueriesData<InfiniteData<CommunityPostPage, string | null>>(
        { queryKey: [...communityKey(memberUuid), "posts", questionUuid] },
        (cached) =>
          cached && {
            ...cached,
            pages: cached.pages.map((page) => ({
              ...page,
              items: page.items.map((post) =>
                post.postUuid === postUuid ? { ...post, isLikedByMe: like.isLiked, likeCount: like.likeCount } : post,
              ),
            })),
          },
      );
    },
  });
}

export function useBlockedMembers() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: [...communityKey(memberUuid), "blocks"],
    queryFn: fetchBlockedMembers,
    enabled: isMemberQueryEnabled,
    retry: false,
  });
}

export function useUnblockMember() {
  const invalidateCommunity = useInvalidateCommunity();
  return useMutation({ mutationFn: unblockMember, onSuccess: invalidateCommunity });
}
