import { useInfiniteQuery, useQuery } from "@tanstack/react-query";
import { fetchNotice, fetchNotices } from "../api/meta";

// 공지 캐시 유지 시간 (1분, 관리자 수정이 늦어도 1분 안에 반영)
const NOTICE_STALE_MILLISECONDS = 1000 * 60;

export const NOTICES_QUERY_KEY = ["notices"] as const;

/** 공지 목록 (페이지 번호 기반 더 보기) (#529) */
export function useNoticeList() {
  return useInfiniteQuery({
    queryKey: [...NOTICES_QUERY_KEY, "list"],
    queryFn: ({ pageParam }) => fetchNotices(pageParam),
    initialPageParam: 0,
    getNextPageParam: (lastPage) => (lastPage.hasNextPage ? lastPage.page + 1 : undefined),
    staleTime: NOTICE_STALE_MILLISECONDS,
    retry: false,
  });
}

/** 공지 1건 (#529) */
export function useNoticeDetail(noticeUuid: string) {
  return useQuery({
    queryKey: [...NOTICES_QUERY_KEY, "detail", noticeUuid],
    queryFn: () => fetchNotice(noticeUuid),
    staleTime: NOTICE_STALE_MILLISECONDS,
    retry: false,
  });
}
