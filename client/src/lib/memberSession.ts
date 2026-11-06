import { useAuthStore } from "../stores/authStore";
import { useDailySetStore } from "../stores/dailySetStore";
import { usePracticeStore } from "../stores/practiceStore";
import { queryClient } from "./queryClient";
import { clearSavedAuthorizationRequest } from "./socialLoginRedirect";

/**
 * 회원 세션 정리 (로그아웃·탈퇴·강제 로그아웃 공통)
 * 토큰·회원 저장값 > 진행 중 풀이 상태 > 서버 데이터 캐시 > 인가 대기값 > Firebase 세션
 * 다음 계정이 이전 회원 데이터를 한 번도 보지 않도록 한 곳에서 모두 비움
 */
export function clearMemberSession(): void {
  // 토큰 먼저 (회원 쿼리 실행 조건이 꺼져 캐시 삭제 직후 재요청 없음)
  useAuthStore.getState().clearTokens();
  useDailySetStore.getState().reset();
  usePracticeStore.getState().reset();
  queryClient.clear();
  clearSavedAuthorizationRequest();
  // Firebase 는 IndexedDB 에 이전 Google·Apple 사용자를 남김 > 동적 import (firebase 초기화를 이 모듈 로딩과 분리)
  void import("./firebase")
    .then(async ({ firebaseAuth }) => {
      const { signOut } = await import("firebase/auth");
      await signOut(firebaseAuth);
    })
    .catch(() => {});
}

// 로그인 화면 경로 (이미 여기면 이동하지 않음 > 새로고침 루프 방지)
const LOGIN_PATH = "/login";

/** 세션 종료 > 회원 세션 정리 > 로그인 화면 (재발급 불가·다른 탭 로그아웃 공통) */
export function clearMemberSessionAndGoToLogin(): void {
  // 로그인 화면에 머무는 경우(새로고침 없음)에도 이전 회원 캐시가 남지 않게 함께 정리
  clearMemberSession();
  if (window.location.pathname !== LOGIN_PATH) {
    window.location.href = LOGIN_PATH;
  }
}
