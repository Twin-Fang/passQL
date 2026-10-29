---
type: issue
id: ISS-0094
created: 2026-04-12
topics: [design-system, question-bank]
symptoms: ["카테고리 카드 밋밋", card-topic, card-topic-icon, "bg-accent-light 미정의", "아이콘 배경 미렌더링", ":active 터치 피드백", "토픽 이름 축약"]
root_cause: "디자인 개선 — 카드가 단순했고, 아이콘 배경에 쓴 bg-accent-light가 프로젝트에 정의돼 있지 않아 렌더링되지 않았다"
status: resolved
resolution: "[[ISS-0094-topic-category-card-ui-report]]"
related: ["[[ISS-0093-admin-topic-edit-button-noop]]"]
source: "https://github.com/Twin-Fang/passQL/issues/169"
---

# ISS-0094: AI문제 풀기 카테고리 카드 UI 개선

GitHub #169 (원본: 이슈 본문과 댓글).

## 증상
`/questions` 토픽 카테고리 카드가 단순하고 밋밋하다. 아이콘 배경색(`bg-accent-light`)이 Tailwind에 정의되지 않아 배경 박스가 안 보인다. 토픽 이름이 카드에 비해 길다.

## 재현 조건
해당 없음 (디자인 개선).

## 조사 기록
- 2026-04-12: 시안 이미지 두 장 뒤 "A 안으로 진행합니다" 댓글. A안의 내용은 이미지에만 있고 텍스트로는 적혀 있지 않다.

## 근본 원인
해당 없음 (디자인 개선). 아이콘 배경 미표시는 미정의 클래스 사용 때문.
