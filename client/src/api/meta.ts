import { apiFetch } from "./client";
import type { TopicTree, ConceptTag, AppConfigResponse } from "../types/api";

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
