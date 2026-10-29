---
type: completion-report
id: ISS-0425
created: 2026-10-28
topics: [community]
status: resolved
resolves: "[[ISS-0425-discussion-feed-delay-stats-refresh]]"
related: ["[[DEC-0203-discussion-stats-refresh-after-commit-event]]"]
source: "https://github.com/Twin-Fang/passQL/issues/739"
---

# ISS-0425 완료 리포트: 노출 상태 변경 이벤트로 커밋 직후 문제 집계 갱신·공용 피드 캐시 삭제

GitHub #739 리포트 댓글 기준 (PR #740, 운영 배포 PR #738). 서버만 변경.

## 해결 방법
- `CommunityDiscussionChangePublisher`: 글 노출 상태가 바뀌면 `CommunityDiscussionChangedEvent(questionUuid)` 발행(문제 의견 글만). 발행 지점: 작성·본인 삭제(`CommunityPostService`), 신고 누적 자동 숨김(`CommunityPostReactionService`), 관리자 숨김·복원·삭제·신고 기각 복원(`CommunityAdminService`).
- `CommunityDiscussionChangedListener`: `AFTER_COMMIT`에 해당 문제 집계 즉시 갱신 + 공용 피드 캐시 삭제.
- `CommunityStatsService.refreshQuestionStats`: 문제 1건을 새 트랜잭션에서 처리(노출 글이 있으면 행 생성·갱신, 없으면 삭제). 점수 계산은 `applyAggregate`로 5분 정기 집계와 공유.
- `CommunityPostRepository.aggregateVisibleOfQuestion`, `CommunityFeedService.evictSharedFeedCache`(hot·trend 키, 접두사 상수 하나).
- 검증: 서버 테스트 48개 통과. 운영 시뮬레이터 — 16:08:16 등록 → 16:08:29 뜨는 토론에 `의견 2 · 방금`, 삭제 직후 `의견 1 · 3시간 전`.

## 근본 원인 (확정)
5분 정기 집계 + 60초 캐시에만 의존.

## 재발 방지
- 좋아요는 즉시 갱신 대상이 아니다(최대 5분 지연 유지).
- 글 노출 상태를 바꾸는 코드를 새로 추가하면 `communityDiscussionChangePublisher.publishChanged(post)`도 호출해야 한다. 빠뜨리면 그 경로만 다시 5분 늦어진다.

## 교훈
(원본에 없음, 볼트 정리) 작성 직후 목록에 안 보이면 저장 실패보다 먼저 집계 주기와 캐시 TTL을 확인한다.
