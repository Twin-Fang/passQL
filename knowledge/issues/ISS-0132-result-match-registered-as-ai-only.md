---
type: issue
id: ISS-0132
created: 2026-04-13
topics: [question-bank, ai]
symptoms: [choiceSetPolicy, AI_ONLY, RESULT_MATCH, "실행 결과로 올바른 것은", "선택지가 SQL 쿼리로 생성", question-single-guide.md, question-bulk-guide.md]
root_cause: "문제 등록 가이드 문서의 JSON 예시·AI 변환 프롬프트가 `AI_ONLY`와 `RESULT_MATCH`의 stem 패턴을 혼동해 기술함"
status: resolved
resolution: "[[ISS-0132-result-match-registered-as-ai-only-report]]"
related: ["[[DEC-0075-stem-pattern-choice-set-policy-mapping]]"]
source: "https://github.com/Twin-Fang/passQL/issues/242"
---

# ISS-0132: "실행 결과로 올바른 것은?" 문제가 `AI_ONLY`로 등록돼 선택지가 SQL 쿼리로 생성됨

GitHub #242 (원본: 이슈 본문과 댓글). 라벨 `긴급`.

## 증상
"다음 SQL의 실행 결과로 올바른 것은?" stem의 EXECUTABLE 문제가 `choiceSetPolicy: AI_ONLY`로 등록돼, 선택지가 결과 테이블이 아니라 "동일한 결과를 내는 SQL" 4개로 생성된다. 사용자 앱에서 "실행 결과를 고르라"는 질문에 SQL 쿼리가 선택지로 나온다.

## 재현 조건
관리자 문제 목록(토픽: 윈도우 함수)에서 stem이 위 문구인 문제 확인 — 예: `b3abd2eb-eaae-4841-95aa-0a44ba9c9320`(LAG 함수 문제). `choiceSetPolicy`가 `AI_ONLY`이고 선택지가 SQL 쿼리 4개.

## 조사 기록
- 2026-04-13: 가이드 문서 수정 완료. 기존에 잘못 등록된 문제 데이터 수정(정책 변경 + 선택지 재생성)은 미완료로 기록.
- 2026-04-13 댓글: Markdown 파일과 프롬프트를 최신으로 복사해야 한다는 안내.

## 근본 원인
`question-single-guide.md`, `question-bulk-guide.md`의 JSON 예시와 AI 변환 프롬프트가 두 정책의 stem 패턴을 혼동했다.
