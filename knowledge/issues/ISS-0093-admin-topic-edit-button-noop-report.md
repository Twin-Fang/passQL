---
type: completion-report
id: ISS-0093
created: 2026-04-12
topics: [admin, question-bank]
status: resolved
resolves: "[[ISS-0093-admin-topic-edit-button-noop]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/168"
---

# ISS-0093 완료 리포트: 토픽 편집 모달과 `PUT /admin/topics/{code}` 구현

GitHub #168 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- 백엔드: `TopicUpdateRequest.java`(`displayName` `@NotBlank`, `sortOrder` `@Min(1)`, `isActive` `@NotNull`), `MetaService.updateTopic()`(더티 체킹), `AdminTopicController` `PUT /admin/topics/{code}`(`@Valid`), `TopicRepository.findAllByOrderBySortOrderAsc()`.
- `MetaService.getTopicTree()`: 활성만 조회(`findByIsActiveTrueOrderBySortOrderAsc`) → 전체 조회. 관리자 화면에서 비활성화 후 되돌릴 수 없던 문제 해결.
- `topics.html`: 편집 모달, `data-code`·`data-name`·`data-sort`·`data-active`로 현재 값 바인딩(`isActive`는 `=== 'true'` 비교), `saveTopicEdit()` → `PUT` 후 새로고침, `.catch()` 처리.

## 근본 원인 (확정)
편집 UI와 API가 없었다. 관리자 목록이 활성 토픽만 조회해 비활성 토픽을 되돌릴 수 없는 문제도 함께 있었다.

## 재발 방지
리포트 주의사항: 관리자 목록에 비활성 토픽이 노출되므로 사용자 API(`/api/topics` 등)의 활성 필터 유지 여부를 별도 확인 필요. 토픽 추가(`POST /admin/topics`)는 HTML 폼만 있고 Controller 미구현 — 별도 이슈 필요.

## 교훈
원본에 적혀 있지 않다.
