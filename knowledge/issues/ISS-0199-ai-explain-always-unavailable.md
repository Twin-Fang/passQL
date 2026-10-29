---
type: issue
id: ISS-0199
created: 2026-10-07
topics: [ai]
symptoms: [AI 해설 사용 불가, "AI 기능이 일시적으로 사용 불가합니다", UnsupportedOperationException, explainError, diffExplain, 서킷브레이커 대체 응답, AI_UNAVAILABLE]
root_cause: "해설 기능이 구현되지 않았다 — 서버 `AiService.explainError`·`diffExplain`이 `throw new UnsupportedOperationException(\"TODO\")`, AI 서버 엔드포인트도 미구현 예외"
status: resolved
resolution: "[[ISS-0199-ai-explain-always-unavailable-report]]"
related: ["[[ISS-0201-ai-explain-model-compare-prompt]]", "[[ISS-0207-ai-explain-sheet-markdown-symbols]]"]
source: "https://github.com/Twin-Fang/passQL/issues/354"
---

# ISS-0199: AI 해설이 항상 '일시적으로 사용 불가'로 표시됨 (기능 미구현)

GitHub #354 (원본: 이슈 본문과 댓글).

## 증상
문제를 틀린 뒤 "AI 해설"을 열면 항상 "AI 기능이 일시적으로 사용 불가합니다."만 표시된다. TestFlight 빌드에서 사용자 확인(2026-10-07).

## 재현 조건
문제(오늘의 세트 등)에서 오답 제출 → AI 해설 열기.

## 조사 기록
- 2026-10-07: 서버 `AiService.explainError`·`diffExplain`이 `throw new UnsupportedOperationException("TODO")` 상태라 서킷브레이커 대체 응답이 항상 나감. Python AI 서버 `/api/ai/explain-error`·`/diff-explain`도 "아직 구현되지 않았습니다" 예외. 서버 로그상 AI 서버로 해설 요청이 가지 않음.
- 2026-10-08: 구현 확인(`AiController` → `AiExplainService`), 로그인 상태 운영 호출은 Google 로그인 자동화 불가·테스트 계정 없음으로 처음엔 미확인. Gemini 키가 서버 IP로 제한돼 로컬 재현 불가.
- 2026-10-08: 운영 end-to-end 확인 완료.

## 근본 원인
기능 미구현 상태에서 실패가 서킷브레이커 대체 응답으로 가려졌다.
