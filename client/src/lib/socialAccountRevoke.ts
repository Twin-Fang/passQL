import { FirebaseError } from "firebase/app";
import {
  GoogleAuthProvider,
  OAuthProvider,
  reauthenticateWithPopup,
  revokeAccessToken,
  signInWithPopup,
  signOut,
  type AuthProvider as FirebaseAuthProvider,
  type UserCredential,
} from "firebase/auth";
import type { AuthProvider } from "../api/auth";
import { appleProvider, firebaseAuth, googleProvider } from "./firebase";

/**
 * 탈퇴 전 제공자 연결 해제 (클라이언트 몫): APPLE 필수 revoke, GOOGLE 최선 revoke
 * KAKAO·NAVER·GITHUB 는 서버가 탈퇴 후 연결 해제 > 여기서는 할 일 없음
 */

/** 연결 해제 결과: 탈퇴 진행 가능 / 사용자 취소 / 실패 / 가입 계정과 다른 계정 인증 (진행 가능 외 전부 탈퇴 중단) */
export type SocialRevokeResult = "READY_TO_WITHDRAW" | "CANCELLED_BY_USER" | "REVOKE_FAILED" | "ACCOUNT_MISMATCH";

// Google OAuth 토큰 폐기 주소 (access token 폐기 시 앱 권한도 함께 해제)
const GOOGLE_TOKEN_REVOKE_URL = "https://oauth2.googleapis.com/revoke";
// 팝업 닫힘·중복 팝업·사용자 취소 오류 코드 3개
const POPUP_CANCELLED_ERROR_CODES: ReadonlySet<string> = new Set([
  "auth/popup-closed-by-user",
  "auth/cancelled-popup-request",
  "auth/user-cancelled",
]);
// 재인증 팝업에서 현재 사용자와 다른 계정 선택 시 오류 코드
const USER_MISMATCH_ERROR_CODE = "auth/user-mismatch";
// Firebase 제공자 ID (현재 Firebase 사용자가 같은 제공자로 로그인했는지 확인용)
const FIREBASE_PROVIDER_ID_BY_AUTH_PROVIDER: Readonly<Partial<Record<AuthProvider, string>>> = {
  APPLE: "apple.com",
  GOOGLE: "google.com",
};

/**
 * 가입 제공자 + 제공자 사용자 ID(Firebase uid) > 탈퇴 전 연결 해제
 * 팝업 차단 방지: 클릭 처리 안에서 다른 await 없이 바로 호출
 */
export async function revokeSocialAccessBeforeWithdraw(
  authProvider: AuthProvider,
  providerUserId: string,
): Promise<SocialRevokeResult> {
  if (authProvider === "APPLE") return revokeAppleAccess(providerUserId);
  if (authProvider === "GOOGLE") return revokeGoogleAccessBestEffort(providerUserId);
  return "READY_TO_WITHDRAW";
}

/** Apple 재인증 팝업 > 가입 계정 대조 > access token > Firebase revokeAccessToken (실패·취소 시 탈퇴 중단) */
async function revokeAppleAccess(providerUserId: string): Promise<SocialRevokeResult> {
  try {
    const userCredential = await reauthenticateWithProvider("APPLE", appleProvider, providerUserId);
    // 다른 Apple 계정 토큰을 revoke 하지 않도록 대조 먼저
    if (userCredential.user.uid !== providerUserId) return signOutMismatchedAccount();
    const credential = OAuthProvider.credentialFromResult(userCredential);
    if (!credential?.accessToken) return "REVOKE_FAILED";
    await revokeAccessToken(firebaseAuth, credential.accessToken);
    return "READY_TO_WITHDRAW";
  } catch (error) {
    return toStoppedResult(error) ?? "REVOKE_FAILED";
  }
}

/** Google 재인증 팝업 > 가입 계정 대조 > access token 폐기 (계정 불일치만 중단, 그 외 실패·취소는 진행) */
async function revokeGoogleAccessBestEffort(providerUserId: string): Promise<SocialRevokeResult> {
  try {
    const userCredential = await reauthenticateWithProvider("GOOGLE", googleProvider, providerUserId);
    if (userCredential.user.uid !== providerUserId) return signOutMismatchedAccount();
    const credential = GoogleAuthProvider.credentialFromResult(userCredential);
    if (!credential?.accessToken) return "READY_TO_WITHDRAW";
    // 외부 Google 주소라 apiFetch 대상 아님, CORS 응답 없이도 요청은 전달되도록 no-cors 단순 요청
    await fetch(GOOGLE_TOKEN_REVOKE_URL, {
      method: "POST",
      mode: "no-cors",
      body: new URLSearchParams({ token: credential.accessToken }),
    });
    return "READY_TO_WITHDRAW";
  } catch (error) {
    // 서버가 Firebase 사용자를 삭제하므로 Google 권한 해제는 최선만 (계정 불일치만 중단)
    return toStoppedResult(error) === "ACCOUNT_MISMATCH" ? "ACCOUNT_MISMATCH" : "READY_TO_WITHDRAW";
  }
}

/** 가입 계정과 다른 계정으로 새로 로그인된 Firebase 세션 정리 > 계정 불일치 */
async function signOutMismatchedAccount(): Promise<SocialRevokeResult> {
  await signOut(firebaseAuth).catch(() => {});
  return "ACCOUNT_MISMATCH";
}

/** 가입 계정의 같은 제공자 Firebase 세션 있으면 재인증(다른 계정 선택 차단), 없으면 새로 로그인 팝업 */
function reauthenticateWithProvider(
  authProvider: AuthProvider,
  provider: FirebaseAuthProvider,
  providerUserId: string,
): Promise<UserCredential> {
  const currentUser = firebaseAuth.currentUser;
  const firebaseProviderId = FIREBASE_PROVIDER_ID_BY_AUTH_PROVIDER[authProvider];
  // 남아 있는 다른 계정 세션으로 재인증하면 가입 계정을 골라도 불일치로 막힘 > uid 까지 확인
  const hasMemberProviderSession =
    currentUser?.uid === providerUserId &&
    currentUser.providerData.some((profile) => profile.providerId === firebaseProviderId);
  if (currentUser && hasMemberProviderSession) return reauthenticateWithPopup(currentUser, provider);
  return signInWithPopup(firebaseAuth, provider);
}

/** Firebase 오류 > 중단 사유 (팝업 취소, 재인증 계정 불일치), 그 외 null */
function toStoppedResult(error: unknown): SocialRevokeResult | null {
  if (!(error instanceof FirebaseError)) return null;
  if (error.code === USER_MISMATCH_ERROR_CODE) return "ACCOUNT_MISMATCH";
  return POPUP_CANCELLED_ERROR_CODES.has(error.code) ? "CANCELLED_BY_USER" : null;
}
