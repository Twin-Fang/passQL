---
type: completion-report
id: ISS-0158
created: 2026-04-26
topics: [home]
status: resolved
resolves: "[[ISS-0158-home-recommendation-api-infinite-loop]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/298"
---

# ISS-0158 완료 리포트: queryKey에서 제외 목록을 빼고 `setQueryData`로 새로고침 처리

GitHub #298 구현 완료 보고 댓글(2026-04-26) 기준.

## 해결 방법
1. queryKey 고정 — `excludeUuids`를 queryKey에서 완전히 제거하고 새로고침은 `setQueryData` 패턴으로 처리.
2. 미인증 차단 — `enabled: !!accessToken`으로 로그인 전 호출 차단.
3. 에러 복구 — `finally`로 `isRefreshing` 복구, `useCallback` 의존성 안정화.

관련 커밋: `997cf7b`(queryKey JSON.stringify 직렬화), `e92aa66`(setQueryData 패턴 전환, 근본 수정), `49ad7c6`(enabled 조건), `b48daf2`(에러 복구 + useCallback 안정화).

## 근본 원인 (확정)
`queryKey`에 `excludeUuids` 배열이 들어가 React Query 캐시 키가 렌더마다 달라졌다.

## 재발 방지
원본에 적혀 있지 않다(위 변경 내용 외).

## 교훈
(원본에 없음, 볼트 정리) React Query가 반복 호출되면 queryKey에 렌더마다 바뀌는 배열·객체가 들어 있는지부터 본다.
