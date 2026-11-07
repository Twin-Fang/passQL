import type { AuthProvider } from "../types/api";

/**
 * 로그인 제공자 표시 (#908): 제공자 이름, 로그인한 계정 표시(이메일 > 제공자 이름), 가입일
 * 앱 login_provider_appearance.dart 와 같은 판정
 */

// 내부 enum(APPLE·KAKAO) 대신 사용자에게 보일 제공자 이름 (#401)
export const LOGIN_PROVIDER_LABEL: Readonly<Record<AuthProvider, string>> = {
  GOOGLE: "Google",
  KAKAO: "카카오",
  NAVER: "네이버",
  GITHUB: "GitHub",
  APPLE: "Apple",
};

// Apple 이메일 가리기 중계 주소 도메인: 사용자가 알아볼 수 없어 이메일로 보이지 않음
const APPLE_HIDDEN_EMAIL_DOMAIN = "@privaterelay.appleid.com";

/** 로그인한 계정 표시: 이메일 > 없음·빈 값·Apple 가림 주소면 제공자 이름 */
export function loginAccountLabelOf(provider: AuthProvider, email: string | null | undefined): string {
  const trimmedEmail = email?.trim() ?? "";
  const isHiddenEmail = trimmedEmail.toLowerCase().endsWith(APPLE_HIDDEN_EMAIL_DOMAIN);
  if (!trimmedEmail || isHiddenEmail) return LOGIN_PROVIDER_LABEL[provider];
  return trimmedEmail;
}

/** 가입 시각(KST, 오프셋 없음) > 점 날짜 (예: 2026.10.16) */
export function formatDottedDate(isoDateTime: string): string {
  const date = new Date(isoDateTime);
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${date.getFullYear()}.${month}.${day}`;
}
