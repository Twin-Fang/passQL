import { useQuery } from "@tanstack/react-query";
import { fetchAppLinks } from "../api/meta";

/**
 * 스토어 링크 조회. 관리자 설정 값이라 자주 바뀌지 않아 길게 캐시한다.
 * 실패해도 화면에는 영향이 없어야 하므로 재시도하지 않고 "링크 없음"으로 취급한다.
 */
export function useAppLinks() {
  const query = useQuery({
    queryKey: ["appLinks"],
    queryFn: fetchAppLinks,
    staleTime: 1000 * 60 * 30,
    retry: false,
  });
  const androidUrl = query.data?.androidUrl ?? null;
  const iosUrl = query.data?.iosUrl ?? null;
  return { androidUrl, iosUrl, hasAny: !!(androidUrl || iosUrl) };
}
