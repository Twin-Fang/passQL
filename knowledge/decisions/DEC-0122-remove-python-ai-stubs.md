---
type: decision
id: DEC-0122
created: 2026-10-15
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0264-architecture-audit-commonization-refactor]]", "[[ISS-0269-ai-stub-removal-settings-unify]]", "[[ISS-0269-ai-stub-removal-settings-unify-report]]", "[[DEC-0113-similar-via-recommend-reuse]]"]
---

# DEC-0122: Python AI 서버의 미구현 스텁 3개(`explain_error`·`diff_explain`·`similar`)를 삭제하고 문서를 정정한다

## 문제 정의 (Context)
AI 서버에 호출되지 않는 스텁 엔드포인트 3개가 있었다 (GitHub #458, #463).

## 결정 (Decision)
소유자 결정 댓글(2026-10-15): 세 기능은 Spring에서 이미 동작한다 — `AiExplainService`는 Gemini를 직접 호출하고, 유사 문제는 `RecommendationService`가 Python `recommend`를 거친다. Python 쪽은 호출되지 않는 껍데기 사본이라 삭제하고 문서를 정정하는 방향으로 진행(댓글 시점 "소유자에게 확인 요청 중"). 같은 날 #463에서 `explain-error`, `diff-explain`, `similar` 스텁과 전용 요청·응답 모델을 삭제했다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`ai/` 라우터·스키마, `ai/CLAUDE.md`, 서버 `AiExplainService`·`RecommendationService`.

## 출처 (References)
- GitHub #458 소유자 결정 댓글 4번 (2026-10-15), GitHub #463 구현 보고서
