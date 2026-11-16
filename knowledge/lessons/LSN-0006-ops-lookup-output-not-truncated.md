---
type: lesson
id: LSN-0006
created: 2026-11-16
reviewed: null
topics: [ops-infra, dev-workflow]
trigger: "운영 서버·DB·관리자 API 조회 결과로 설정값·스위치 상태를 판단할 때 (head·tail·글자 수 제한으로 출력을 줄이려 할 때)"
status: active
source: "2026-11-16 세션, ISS-0531"
supersedes: null
superseded_by: null
related: ["[[ISS-0531-ox-quiz-leitner-review]]", "[[ISS-0531-ox-quiz-expected-pass-lock-screen-ox-report]]"]
---

# LSN-0006: 운영 조회 출력은 판단에 필요한 키가 보일 때까지 자르지 않는다 — 잘린 출력에 값이 없으면 "꺼짐"이 아니라 "못 봄"이다

## 규칙
운영 설정·스위치 상태를 판단하는 조회는 출력을 짧게 자르지 말고, 필요한 키만 골라(필터·`jq` 등) 끝까지 본다. 잘린 출력에서 값을 찾지 못했으면 "꺼져 있다"고 결론 내지 않고 다시 조회한다.

## Why
#1083(OX 퀴즈) 작업 중 운영 조회 출력을 짧게 잘라 본 탓에, 이미 켜져 있던 개념 학습 공개 스위치를 꺼져 있다고 잘못 판단했다. 실제로는 켜져 있었다(무료 단원 2개, #1083 보고서). OX 카드 노출이 이 스위치에 달려 있어 잘못 판단하면 불필요한 운영 변경으로 이어질 수 있었다.

## How to apply
- 운영 조회는 대상 키로 먼저 좁히고(`grep 키`, `jq '.키'`), 줄 수·글자 수 제한은 그 뒤에만 쓴다.
- 결론(켜짐/꺼짐, 있음/없음)을 말할 때는 그 값이 보인 출력 줄을 근거로 든다.
- 운영 설정을 바꾸기 전에는 잘리지 않은 조회로 현재 값을 한 번 더 확인한다.
