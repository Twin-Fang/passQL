---
type: lesson
id: LSN-0002
created: 2026-11-14
reviewed: null
topics: [question-bank, dev-workflow]
trigger: "하네스로 만든 문제를 운영에 가져오기(import) 직전"
status: active
source: "ISS-0519"
supersedes: null
superseded_by: null
related: ["[[ISS-0519-sqld-round63-trend-new-questions]]", "[[DEC-0277-no-dash-middle-dot-server-cleaner]]", "[[ISS-0474-question-format-rule-forbidden-punctuation]]"]
---

# LSN-0002: 하네스 lint 통과는 서버 형식 규칙 통과가 아니다 — 가져오기 전에 서버 형식 규칙을 따로 확인한다

## 규칙
하네스로 만든 문제를 운영에 가져오기 전에, 하네스 lint 와 별도로 서버 문항 형식 규칙(`QuestionFormatRule`, #905)에 걸리는지 확인하고 고친 뒤 등록한다.

## Why
#1074(63회)에서 lint 를 통과한 38건 중 24건이 운영 가져오기에서 서버 형식 규칙 위반으로 건너뛰어졌다. 원인은 줄표·가운뎃점 38곳, SELECT 목록 줄바꿈 15곳, 지문 자료형 표기 4곳이었다. 가져오기는 위반 건을 건너뛰므로([[DEC-0277-no-dash-middle-dot-server-cleaner]]) 수정 후 재등록이 한 번 더 필요했다.

## How to apply
- 가져오기 전 점검 항목: 줄표·가운뎃점, SELECT 목록 서식, 지문 자료형 다시 적기, 그 밖의 `QuestionFormatRule` 사유.
- 가져오기 결과에서 건너뛴 건수와 사유를 반드시 확인하고, 수정 후 같은 건만 재등록한다.
