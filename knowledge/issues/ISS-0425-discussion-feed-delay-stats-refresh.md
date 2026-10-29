---
type: issue
id: ISS-0425
created: 2026-10-28
topics: [community]
symptoms: ["토론 의견 바로 안 보임", "최대 6분 지연", question_discussion_stats, CommunityStatsScheduler, "뜨는 토론", "피드 캐시 60초"]
root_cause: "토론 피드가 5분마다 갱신되는 question_discussion_stats 집계를 기준으로 채워지고 공용 탭은 Redis에 60초 캐시돼, 새 글이 다음 집계와 캐시 만료까지 보이지 않았다"
status: resolved
resolution: "[[ISS-0425-discussion-feed-delay-stats-refresh-report]]"
related: ["[[DEC-0203-discussion-stats-refresh-after-commit-event]]"]
source: "https://github.com/Twin-Fang/passQL/issues/739"
---

# ISS-0425: 토론 의견을 써도 토론장에 바로 보이지 않음 (5분 집계 대기)

GitHub #739 (원본: 이슈 본문과 댓글).

## 증상
토론에 의견을 써도 토론장(뜨는 토론·최신 경향·내가 푼 문제)에 바로 보이지 않고 최대 약 6분 뒤에 나타난다. 글을 쓴 사람은 방금 올린 글이 사라진 것처럼 느낀다. 운영 확인: 2시간 전 글은 모든 탭에 정상 노출 — 저장은 정상, 노출만 늦다.

## 재현 조건
1. 문제를 풀고 의견 등록
2. 바로 토론 탭 > 뜨는 토론
3. 방금 쓴 글이 있는 문제가 목록에 없음

## 조사 기록
- 피드는 `question_discussion_stats` 집계 기준, `CommunityStatsScheduler`가 5분마다 갱신(GitHub #525). 회원과 무관한 탭(뜨는 토론·최신 경향)은 Redis 60초 캐시.
- 앱은 원래 의견 작성 후 피드를 다시 요청(`_refreshAfterContentChange`) — 서버만 고치면 됨.
- 2026-10-28: PR #740, 운영 배포는 PR #738에 함께.

## 근본 원인
글 노출 상태 변경이 집계·캐시에 즉시 반영되지 않는 구조.
