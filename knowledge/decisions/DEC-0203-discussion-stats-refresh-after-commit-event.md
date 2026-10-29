---
type: decision
id: DEC-0203
created: 2026-10-28
reviewed: null
topics: [community]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0425-discussion-feed-delay-stats-refresh]]", "[[ISS-0425-discussion-feed-delay-stats-refresh-report]]"]
---

# DEC-0203: 토론 글 노출 상태가 바뀌면 이벤트로 커밋 직후 그 문제 집계만 즉시 갱신하고 공용 피드 캐시를 비운다 (5분 정기 집계는 유지)

## 문제 정의 (Context)
토론 피드가 5분 정기 집계(GitHub #525)와 60초 캐시 기준이라 새 의견이 최대 약 6분 뒤에 보였다 (GitHub #739).

## 결정 (Decision)
- 의견 작성·삭제·숨김·복원·관리자 삭제·신고 자동 숨김 시 `CommunityDiscussionChangedEvent`를 발행하고, `AFTER_COMMIT` + `REQUIRES_NEW`로 해당 문제 집계를 갱신한 뒤 공용 피드 캐시를 삭제한다. 갱신이 실패해도 글쓰기는 성공으로 두고 로그만 남긴다(정기 집계가 보정).
- 5분 정기 집계는 점수 감쇠와 좋아요 반영용으로 그대로 둔다.

## 검토한 대안 (Alternatives)
리포트 「왜 이렇게 했나」:
- 커밋 전 갱신: 방금 쓴 글이 안 보일 수 있고 갱신 실패로 원래 요청까지 롤백될 수 있어 버림.
- 서비스마다 집계·캐시 처리를 직접 넣기: 노출 상태가 바뀌는 곳이 6곳이라 같은 코드가 6번 생겨 이벤트로 분리.
- 정기 집계 없애기: 시간에 따른 점수 감쇠와 좋아요(글마다 이벤트 없음)를 맡아야 해서 유지.

## 결과 (Consequences)
**긍정**
- 작성 후 약 13초 안에 뜨는 토론에 반영(운영 시뮬레이터).

**부정**
- 좋아요 수·점수는 여전히 최대 5분 지연.
- 노출 상태를 바꾸는 새 코드는 반드시 `publishChanged(post)`를 호출해야 한다.

## 영향 범위 (Scope)
`CommunityDiscussionChangePublisher`, `CommunityDiscussionChangedListener`, `CommunityStatsService`, `CommunityFeedService`, `CommunityPostService`, `CommunityPostReactionService`, `CommunityAdminService`.

## 출처 (References)
- GitHub #739 이슈 본문 「예상 동작」, 리포트 「왜 이렇게 했나」
- [[ISS-0425-discussion-feed-delay-stats-refresh]]
