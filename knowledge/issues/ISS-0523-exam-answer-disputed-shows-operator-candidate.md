---
type: issue
id: ISS-0523
created: 2026-11-16
topics: [practice]
symptoms: ["가답안 갈림", "DISPUTED", "운영 후보 답", "정답 ?", "득표 1위", "가채점 참여 적음", "63회 15문항", "exam-answers", "ExamAnswerKeyResolver", "isOperatorCandidateShown", "배포 직후 이전 규칙 응답"]
root_cause: "표시 정답 규칙이 운영 가답안을 LEADING·CONFIRMED·OFFICIAL 에서만 써서, 갈림 문항은 운영 후보 답이 있어도 득표 1위(참여 적으면 없음)만 보였다"
status: resolved
resolution: "[[ISS-0523-exam-answer-disputed-shows-operator-candidate-report]]"
related: ["[[DEC-0320-exam-answer-disputed-shows-operator-candidate]]", "[[DEC-0316-exam-answer-two-sources-operator-first]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]"]
source: "_sources/issues/ISS-0523-exam-answer-disputed-shows-operator-candidate.md"
---

# ISS-0523: 가답안 갈림 문항에 운영 후보 답 표시

GitHub #1101 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1101 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1101#issuecomment-6897051400 · PR #1103 (머지) · 릴리스 PR #1105 (서버만)

## 증상
- 회차별 가답안에서 운영 가답안 상태가 "갈림"인 문항은 운영 후보 답이 있어도 화면에는 사용자 득표 1위만 정답으로 보였다.
- 가채점 참여가 적을 때 갈림 문항 정답이 "?"로 보였다. 63회는 15문항.

## 재현 조건
운영 가답안 상태 `DISPUTED` + 운영 답 입력됨 + 해당 문항 득표 없음 > 공개 API `answer` null.

## 조사 기록
- 2026-11-15: [[ISS-0520-sqld-round-answer-key-omr-grading]] 완료 리포트 검증에서 이미 관찰("갈림 문항은 득표 1위가 정답으로 보이며, 참여가 쌓이기 전에는 ?"). 원인은 [[DEC-0316-exam-answer-two-sources-operator-first]] 표시 규칙.
- 2026-11-16: `ExamAnswerKeyResolver` 에서 표시 판정과 확정 채점 판정을 분리(커밋 1a53215c), 핵심 판정 테스트 3개, API 설명·계약·웹 타입 갱신.

## 근본 원인
표시 규칙이 확정 채점 조건(신뢰 상태)과 하나로 묶여 있어, 갈림 문항은 운영 후보 답을 보여 줄 경로가 없었다(설계상 규칙, 버그 아님).
