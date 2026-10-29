---
type: issue
id: ISS-0032
created: 2026-04-09
topics: [admin, question-bank]
symptoms: ["문제 직접 등록 불가", "/admin/questions/register", "AI 생성 플로우 강제", createQuestionOnly, answerSql]
root_cause: "관리자 문제 등록이 AI 생성 플로우(`/admin/questions/new`)로만 가능했고 선택지 없이 문제만 저장하는 경로가 없었다"
status: resolved
resolution: "[[ISS-0032-admin-direct-question-register-report]]"
related: ["[[DEC-0028-realtime-choice-set-with-prefetch]]"]
source: "https://github.com/Twin-Fang/passQL/issues/46"
---

# ISS-0032: 관리자 퀴즈 문제 직접 등록

GitHub #46 (원본: 이슈 본문과 댓글).

## 증상
관리자가 문제를 등록하려면 AI 생성 플로우(`/admin/questions/new`)를 반드시 거쳐야 했다. stem, schema, answerSql 등을 직접 입력해 저장하는 경로가 없었고, 선택지 없이 문제만 먼저 저장한 뒤 AI가 선택지를 자동 생성하는 워크플로우가 지원되지 않았다.
제안: `/admin/questions/register` GET/POST, `QuestionGenerateService.createQuestionOnly()`(선택지 없이 Question만 저장), `ExecutionMode.EXECUTABLE`일 때 schemaDdl·answerSql 필수 검증, `question-register.html`(토픽, 난이도, stem, schema, answerSql, hint, choiceSetPolicy).

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-09: 직접 등록 UI, 개념형/실행형 화면, 정답 실행 SQL 테스트 화면 캡처 댓글. 프론트 담당 확인 요청.

## 근본 원인
해당 없음 (기능 이슈).
