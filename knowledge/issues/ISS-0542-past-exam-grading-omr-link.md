---
type: issue
id: ISS-0542
created: 2026-11-17
topics: [practice, question-bank, admin]
symptoms: ["지난 회차 가채점", "이전 시험 가채점", "hasExamAnswerKey", "isPastSettledRound", "기출 복원 탭 가채점 진입", "복원 자료 기준 정답", "past-exam-answer-key", "지난 회차 정답 데이터 없음", "원래 정답 번호 없음 보기 섞기"]
root_cause: "가답안·OMR 가채점이 63회에만 열려 있었고 지난 회차는 회차 행·정답 데이터·앱 진입이 없었다(기능 부재, 서버 모델은 이미 회차 번호 다중 지원)"
status: open
resolution: null
related: ["[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[ISS-0535-past-exam-restored-rounds]]", "[[DEC-0344-past-exam-grading-reuses-answer-key-round]]", "[[DEC-0327-answer-key-highlight-exam-date-plus-7]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]"]
source: "_sources/issues/ISS-0542-past-exam-grading-omr-link.md"
---

# ISS-0542: 지난 회차 기출 OMR 가채점과 회차 풀이 연결

GitHub #1151 (열림, 작업중 — 지난 회차 정답 운영 입력 남음). 원본: https://github.com/Twin-Fang/passQL/issues/1151 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1151#issuecomment-6937030195 · PR #1152 (main 머지, 배포 전)

## 증상
63회에만 가답안·OMR 가채점이 있어 지난 회차(45~62회) 응시자가 이전 시험을 다시 채점할 수 없었다. 기출 복원 풀이(ISS-0535)와 가채점이 이어져 있지도 않았다.

## 재현 조건
앱 > 모의고사 > 기출 복원 탭. 가채점 진입 없음. 홈 가답안 카드는 시험일 + 7일까지만([[DEC-0327-answer-key-highlight-exam-date-plus-7]]).

## 조사 기록
- 2026-11-17: 현황 조사 — 서버 `exam_answer_round` 는 (자격증, 회차 번호) 유일이라 회차 행만 더하면 되고 공개 API·관리자 입력 API 도 회차 수 제한이 없다. 기출 복원 풀이(실전·학습, 서버 채점)도 이미 있다. 없는 것은 지난 회차 정답 데이터와 앱 진입.
- 2026-11-17: 정답 원본 — 다시 쓴 YAML 은 보기 순서를 섞어 원래 정답 번호가 없다. 복원 정답은 `recall-tables.md` 에 58~62회만(복원 사이트 표기, 공식 아님). 45~57회 확보 방법 없음.
- 2026-11-17: 구현 — 기출 회차 응답 `hasExamAnswerKey`, 앱 [지난 회차 가채점] 행·회차 시트, 지난 회차 득표 숨김·기출 풀기 연결, 로컬 운영 입력·롤백 스크립트. 비교 사이트 조사는 이전 보고서(2026-11-16)를 재사용.
- 남은 일(사용자): 정답 출처·공개 범위 결정, 운영 입력(스크립트 점검 > `--execute`), 앱 배포 동반.

## 근본 원인
기능 부재. 확정은 운영 입력 후 완료 리포트에서.
