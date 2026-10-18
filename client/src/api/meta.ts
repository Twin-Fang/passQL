import { apiFetch } from "./client";
import type { TopicTree, ConceptTag, AppConfigResponse, AppNotice, AppNoticePage } from "../types/api";

export function fetchTopics(): Promise<TopicTree[]> {
  return apiFetch("/meta/topics");
}

export function fetchTags(): Promise<ConceptTag[]> {
  return apiFetch("/meta/tags");
}

// 스토어 다운로드 링크 — 출시 전이거나 비어 있으면 null (#433)
export interface AppLinks {
  readonly androidUrl: string | null;
  readonly iosUrl: string | null;
}

export function fetchAppLinks(): Promise<AppLinks> {
  return apiFetch("/meta/app-links");
}

/** 시작 설정 조회: 점검 상태, 노출 공지 (인증 불필요, 점검 중에도 응답) (#464) */
export function fetchAppConfig(): Promise<AppConfigResponse> {
  return apiFetch("/meta/app-config");
}

// 공지 목록 페이지 크기 (서버 기본값과 같음)
export const NOTICE_PAGE_SIZE = 20;

/** 공지 목록 한 페이지 (지난 공지 포함, 인증 불필요) (#529) */
export function fetchNotices(page: number, size: number = NOTICE_PAGE_SIZE): Promise<AppNoticePage> {
  const params = new URLSearchParams({ page: String(page), size: String(size) });
  return apiFetch(`/meta/notices?${params}`);
}

/** 공지 1건 (없음·비활성·노출 전 > 404 APP_NOTICE_NOT_FOUND) (#529) */
export function fetchNotice(noticeUuid: string): Promise<AppNotice> {
  return apiFetch(`/meta/notices/${encodeURIComponent(noticeUuid)}`);
}
