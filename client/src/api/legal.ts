import { apiFetch } from "./client";
import type { LegalResponse, LegalType } from "../types/api";

// 응답 전·실패 시에도 어떤 문서인지 보이도록 쓰는 기본 제목 (#403)
export const LEGAL_TITLE: Record<LegalType, string> = {
  TERMS_OF_SERVICE: "이용약관",
  PRIVACY_POLICY: "개인정보처리방침",
};

export function fetchLegal(type: LegalType): Promise<LegalResponse> {
  return apiFetch<LegalResponse>(`/meta/legal/${type}`);
}
