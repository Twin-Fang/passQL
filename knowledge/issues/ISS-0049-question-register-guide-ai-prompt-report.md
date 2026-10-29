---
type: completion-report
id: ISS-0049
created: 2026-04-11
topics: [question-bank, admin]
status: resolved
resolves: "[[ISS-0049-question-register-guide-ai-prompt]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/89"
---

# ISS-0049 완료 리포트: 단건·벌크 가이드 전면 재작성과 3유형 완성 예시

GitHub #89 `## 개요` 리포트 댓글(2026-04-11) 기준.

## 해결 방법
- `server/PQL-Web/src/main/resources/static/docs/question-register-guide.md` 전면 재작성: `schemaDisplay` 추가, `executionMode` 판별 기준표, ODD_ONE_OUT 규칙(`answerSql` = 소수 쪽 SQL), `schemaDdl` 규칙(MariaDB 호환, FK 순서), difficulty 5단계 기준, 3유형(EXECUTABLE·ODD_ONE_OUT·CONCEPT_ONLY) 완성 예시 JSON.
- `question-bulk-guide.md` 전면 재작성: 같은 항목, 배열 형식 강제 안내, 3유형 예시 배열.
- `questions.html`: 벌크 가이드 모달의 AI 프롬프트 복사 버튼을 모달 헤더 우측으로 이동.

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
리포트 주의사항: `question-register.html` 모달의 하드코딩 JSON 스키마(`<pre>`)는 수정되지 않았고 `choiceSetPolicy`가 없다. 벌크 모달의 `BULK_AI_PROMPT` JS 상수는 MD 파일과 별도로 관리된다 — 동기화 자동화 검토 필요.

## 교훈
(원본에 없음, 볼트 정리) 프롬프트 원본이 MD와 JS 상수 두 곳에 있으면 한쪽만 고쳐지기 쉽다.
