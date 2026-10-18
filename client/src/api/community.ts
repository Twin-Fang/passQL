import { apiFetch } from "./client";
import type {
  BlockedMember,
  CommunityFeedPage,
  CommunityPost,
  CommunityPostCreatePayload,
  CommunityPostLike,
  CommunityPostPage,
  CommunityReportPayload,
} from "../types/api";

// 피드 탭 > 서버 source 값
export type CommunityFeedSource = "hot" | "trend" | "solved" | "mine";
export type CommunityPostSort = "latest" | "likes";

export const COMMUNITY_POST_PAGE_SIZE = 20;

/** 피드 (커서 기반, 탭별) */
export function fetchCommunityFeed(source: CommunityFeedSource, cursor: string | null): Promise<CommunityFeedPage> {
  const params = new URLSearchParams({ source });
  if (cursor) params.set("cursor", cursor);
  return apiFetch(`/community/feed?${params}`);
}

/** 문제별 의견 목록 (풀지 않았으면 400 COMMUNITY_SOLVE_REQUIRED) */
export function fetchCommunityPosts(
  questionUuid: string,
  sort: CommunityPostSort,
  cursor: string | null,
): Promise<CommunityPostPage> {
  const params = new URLSearchParams({ sort, size: String(COMMUNITY_POST_PAGE_SIZE) });
  if (cursor) params.set("cursor", cursor);
  return apiFetch(`/community/questions/${encodeURIComponent(questionUuid)}/posts?${params}`);
}

export function createCommunityPost(questionUuid: string, payload: CommunityPostCreatePayload): Promise<CommunityPost> {
  return apiFetch(`/community/questions/${encodeURIComponent(questionUuid)}/posts`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function deleteCommunityPost(postUuid: string): Promise<void> {
  return apiFetch(`/community/posts/${encodeURIComponent(postUuid)}`, { method: "DELETE" });
}

export function toggleCommunityPostLike(postUuid: string): Promise<CommunityPostLike> {
  return apiFetch(`/community/posts/${encodeURIComponent(postUuid)}/like`, { method: "PUT" });
}

export function reportCommunityPost(postUuid: string, payload: CommunityReportPayload): Promise<void> {
  return apiFetch(`/community/posts/${encodeURIComponent(postUuid)}/report`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function blockCommunityPostAuthor(postUuid: string): Promise<void> {
  return apiFetch(`/community/posts/${encodeURIComponent(postUuid)}/block-author`, { method: "POST" });
}

export function fetchBlockedMembers(): Promise<BlockedMember[]> {
  return apiFetch("/members/me/blocks");
}

export function unblockMember(blockUuid: string): Promise<void> {
  return apiFetch(`/members/me/blocks/${encodeURIComponent(blockUuid)}`, { method: "DELETE" });
}
