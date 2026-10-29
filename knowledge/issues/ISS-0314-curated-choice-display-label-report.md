---
type: completion-report
id: ISS-0314
created: 2026-10-26
topics: [practice]
status: resolved
resolves: "[[ISS-0314-curated-choice-display-label]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/512"
---

# ISS-0314 완료 리포트: 화면 순서로 A~D 표시 라벨, 채점은 `choiceKey` 그대로

GitHub #512 구현 완료 댓글(2026-10-17)과 리포트 댓글(2026-10-26) 기준.

## 해결 방법
- 공통 함수 `choice_display_label.dart`: 화면 순서 0..3 → A..D, choiceKey → 화면 라벨 변환.
- 보기 카드(`ChoiceItemCard.displayLabel`), 챕터 결과 바 "정답 X", 결과 화면 "정답 (X)"를 화면 순서 라벨로 표시. 결과 화면은 `QuestionResultArguments`로 정답 표시 라벨을 받는다.
- 웹은 보기에 키 글자를 표시하지 않아 수정 대상 아님.
- 스토어 "새로운 기능" 문구를 공통 고정 문구로 지정(`37a1aef7`).
- v1.10.0부터 반영, 심사 통과한 1.51.1 포함 이후 스토어 빌드에 모두 들어 있다.

## 근본 원인 (확정)
표시 라벨과 채점 키를 구분하지 않았다.

## 재발 방지
표시 라벨과 채점 키는 서로 다른 값이다. 서버로 보내는 값을 표시 라벨로 바꾸면 고정 보기 문제의 채점이 틀어진다. 테스트 `choice_display_label_test` 3건.

## 교훈
(원본에 없음, 볼트 정리) 서버가 보기 순서를 섞는 문제에서는 화면 라벨을 순번으로 계산하고, 채점·서버 통신에는 원래 키만 쓴다.
