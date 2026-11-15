---
type: completion-report
id: ISS-0523
created: 2026-11-16
topics: [practice]
status: resolved
resolves: "[[ISS-0523-exam-answer-disputed-shows-operator-candidate]]"
related: ["[[DEC-0320-exam-answer-disputed-shows-operator-candidate]]", "[[DEC-0316-exam-answer-two-sources-operator-first]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1101#issuecomment-6897051400"
---

# ISS-0523 완료 리포트: 갈림 문항도 운영 후보 답을 표시, 채점은 점수 범위 유지

PR #1103 머지 · 릴리스 PR #1105 (서버만 배포, 앱 변경 없어 심사 제출 없음)

## 해결 방법
- `ExamAnswerItemStatus.isOperatorCandidateShown()` 추가(DISPUTED). `ExamAnswerKeyResolver` 가 `isOperatorAnswerUsed`(확정 채점: LEADING·CONFIRMED·OFFICIAL)와 `isOperatorAnswerShown`(표시: 신뢰 상태 + 갈림)을 따로 계산 — [[DEC-0320-exam-answer-disputed-shows-operator-candidate]].
- `ExamAnswerItemResponse.answer` 설명, `api-contract/openapi.json`, 웹 타입 재생성.
- 소개 사이트도 서버 스냅샷으로 재배포(48문항 표시).

## 근본 원인 (확정)
표시 정답과 확정 채점이 같은 조건(신뢰 상태)을 공유해, 갈림 문항은 운영 후보 답을 보여 줄 수 없었다.

## 검증
- `ExamAnswerKeyResolverTest` 3개: 갈림+득표 없음 > 후보 답·미확정, 갈림이 득표 1위보다 우선, 모름은 득표 1위.
- 운영 공개 API `GET /api/exam-answers/SQLD/63`: 갈림 15문항 중 운영 후보 답 있는 13문항 표시(2·45번 표시, 39·44번 운영 답 ③), 정답 빈 문항은 29(미복원)·47(후보 없음)만. 채점은 그대로(갈림 = 점수 범위).
- 같은 시각 다른 세션의 릴리스 #1104(앱 포함)가 먼저 실행됨 — 이번 작업과 무관.

## 재발 방지
- 표시와 채점 판정은 의도적으로 분리 — 다시 하나의 조건으로 묶지 않는다.
- 클라이언트는 `answerStatus = DISPUTED` 표시를 유지해야 숫자가 확정 정답으로 오해되지 않는다.

## 교훈
- 배포 직후 수 분간 공개 API 가 이전 규칙으로 응답했는데, 서버 재기동이 늦게 끝난 것이었다. 배포 후 실측이 이전 동작이면 코드 회귀를 의심하기 전에 재기동 완료부터 확인한다.
