import { useAuthStore } from "../stores/authStore";

/**
 * 회원별 쿼리 공통 범위: 캐시 키(memberUuid) + 실행 조건(토큰·UUID 보유)
 * 키에 accessToken 대신 memberUuid — 토큰 갱신마다 전체 재요청 방지 (#497)
 */
export function useMemberQueryScope() {
  const memberUuid = useAuthStore((state) => state.memberUuid);
  // boolean 구독: 토큰 값이 바뀌어도 리렌더 없음
  const hasAccessToken = useAuthStore((state) => state.accessToken !== null);
  return { memberUuid, isMemberQueryEnabled: hasAccessToken && memberUuid !== null };
}
