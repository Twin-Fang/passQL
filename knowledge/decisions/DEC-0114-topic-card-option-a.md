---
type: decision
id: DEC-0114
created: 2026-10-08
reviewed: null
topics: [design-system, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0253-topic-card-design-request]]", "[[ISS-0253-topic-card-design-request-report]]", "[[ISS-0252-app-topic-card-icons]]", "[[ISS-0252-app-topic-card-icons-report]]"]
---

# DEC-0114: 앱 토픽 선택 카드는 별도 시안 없이 보드의 A안(토픽별 색 + 큰 칩)으로 간다

## 문제 정의 (Context)
토픽 카드를 시안 없이 먼저 구현했는데 밋밋하고 큰 글자에서 이름이 잘렸다 (GitHub #446, #447).

## 결정 (Decision)
보드의 **A안**으로 확정: 토픽별 색 아이콘 칩(44px), 화살표 오른쪽 위 고정, 서브토픽 개수 알약, 카드 비율 1.4 고정 대신 글자 배율만큼 카드 높이 증가. 웹 카테고리 버튼은 이번에 맞추지 않는다.

## 검토한 대안 (Alternatives)
- 보드의 다른 배치·표현 대안: 원본에서는 이미지(`04_alternatives`)로만 제시돼 내용을 옮길 수 없다. 개발 쪽 추천 이유는 "토픽마다 색이 달라 구분이 빠르고 화살표·개수 알약 위치가 통일됩니다".
- 디자이너 시안을 기다리기: 하지 않고 A안으로 진행. 시안이 나오면 새 이슈로 다시 다듬는다.

## 결과 (Consequences)
**긍정**
- 글자 200%·긴 이름 잘림 해소(코드 렌더 확인).

**부정**
- 토픽별 색 9개가 토큰이 아니라 코드에 정의됨(원본: 토큰 이동은 따로 할 수 있음).
- 웹과 앱 카드 모양이 다르게 남음.

## 영향 범위 (Scope)
앱 `TopicCard`, 토픽 그리드, `app/lib/core/topic_icons.dart`.

## 출처 (References)
- GitHub #447 확정 댓글 (2026-10-08), GitHub #446 배포 완료 댓글 (2026-10-10)
