import { apiFetch } from "./client";
import type { TopicTree, ConceptTag } from "../types/api";

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
