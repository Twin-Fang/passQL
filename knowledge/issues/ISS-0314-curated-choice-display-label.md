---
type: issue
id: ISS-0314
created: 2026-10-16
topics: [practice]
symptoms: [보기 라벨 뒤섞임, "C, A, D, B", choiceKey 라벨, choice_item_card.dart, 정답 B 표기, CURATED_ONLY 셔플]
root_cause: "앱이 보기 라벨을 `choiceKey` 글자 그대로 그려, 서버가 CURATED_ONLY 보기 순서를 섞으면 라벨이 뒤섞임"
status: resolved
resolution: "[[ISS-0314-curated-choice-display-label-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/512"
---

# ISS-0314: 고정 보기 문제 보기 라벨을 표시 순번 기준으로 표시

GitHub #512 (원본: 이슈 본문과 댓글).

## 증상
`CURATED_ONLY` 고정 보기 문제는 서버가 풀이 응답마다 보기 순서를 섞는다(GitHub #511). 앱은 보기 라벨을 `choiceKey` 그대로 그려(`choice_item_card.dart`의 `keyLabel: item.key`, 결과 화면 "정답 B") 라벨이 C, A, D, B처럼 뒤섞여 보인다. 섞기의 목적(정답 위치 암기 방지)이 약해지고 화면도 어색하다.

## 재현 조건
앱에서 CURATED_ONLY 문제 풀이 화면 진입.

## 조사 기록
- 2026-10-17: main `3f84e154` 반영, 스토어 배포 대기로 이슈 유지.
- 2026-10-26: 리포트 후 닫힘.

## 근본 원인
라벨과 채점 키를 같은 값(`choiceKey`)으로 썼다.
