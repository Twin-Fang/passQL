import { QueryClient } from "@tanstack/react-query";
import { shouldRetry } from "../api/retry";

/**
 * 앱 전체 서버 데이터 캐시 단일 인스턴스
 * 컴포넌트 밖(로그아웃·강제 로그아웃)에서도 회원 캐시를 비우도록 모듈로 둠
 */
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,
      // 화면 이탈 후 캐시 보관 30분 (기본 5분이면 staleTime 10~30분 쿼리가 복귀 시 재요청), AI 코멘트는 쿼리별 더 길게
      gcTime: 1000 * 60 * 30,
      retry: shouldRetry,
      refetchOnWindowFocus: false,
    },
  },
});
