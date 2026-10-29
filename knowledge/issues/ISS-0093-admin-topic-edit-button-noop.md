---
type: issue
id: ISS-0093
created: 2026-04-12
topics: [admin, question-bank]
symptoms: ["토픽 편집 버튼 동작 없음", "editTopic()", "alert('편집: ' + code)", "topics.html", "비활성 토픽 목록 누락"]
root_cause: "admin topics.html의 editTopic()이 alert만 호출하고 편집 모달·API가 미구현"
status: resolved
resolution: "[[ISS-0093-admin-topic-edit-button-noop-report]]"
related: ["[[ISS-0094-topic-category-card-ui]]"]
source: "https://github.com/Twin-Fang/passQL/issues/168"
---

# ISS-0093: 관리자 토픽 편집 버튼 클릭 시 동작 없음

GitHub #168 (원본: 이슈 본문, "Stable 적용 완료" 댓글, 리포트 댓글).

## 증상
관리자 토픽/태그 관리 화면에서 편집(연필) 버튼을 누르면 `alert`만 뜨고 편집 UI가 없다.

## 재현 조건
관리자 페이지 → 토픽/태그 관리 → 토픽 편집 버튼.

## 조사 기록
- 2026-04-12: `PQL-Web/src/main/resources/templates/admin/topics.html` 220번째 줄 `editTopic()`이 `alert('편집: ' + code)`로만 구현.

## 근본 원인
편집 기능 미구현.
