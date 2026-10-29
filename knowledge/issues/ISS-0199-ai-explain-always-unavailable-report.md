---
type: completion-report
id: ISS-0199
created: 2026-10-08
topics: [ai]
status: resolved
resolves: "[[ISS-0199-ai-explain-always-unavailable]]"
related: ["[[ISS-0201-ai-explain-model-compare-prompt]]"]
source: "https://github.com/Twin-Fang/passQL/issues/354"
---

# ISS-0199 완료 리포트: `AiExplainService` 구현, 운영 해설 호출 200 확인

GitHub #354 검증 댓글 두 건 기준 (2026-10-08, 운영 v0.5.1). `## 개요` 형식 리포트는 없음.

## 해결 방법
- `AiController`가 `AiExplainService`를 호출한다. 이전의 `UnsupportedOperationException("TODO")`는 이 경로에 없다.
- 운영 해설 프롬프트: `diff_explain` v2, `explain_error` v2 모두 `gemini-3.5-flash-lite` 활성 (GitHub #356).
- 웹 `AiExplanationSheet` 결함 두 가지 수정(PR #445, v0.5.1): 요청 실패 시 빈 화면 → 오류 안내, 하단 모델 정보가 `프롬프트 v1 · qwen2.5:7b`로 고정 표기 → 일반 안내 문구.
- 부수: 앱 CI가 낡은 테스트 1건과 정적 분석 5건으로 실패하던 것을 함께 고침.

## 근본 원인 (확정)
해설 기능 미구현.

## 재발 방지
서버 `AiExplainServiceTest` 4/4(캐시, 선택지 세트 비교, AI 실패 시 `AI_UNAVAILABLE`, 오류 해설 입력), 앱 `AiExplainSheet` 위젯 테스트 3건, 웹 컴포넌트 테스트 5건, 앱 전체 테스트 169건. 운영 E2E: 운영 웹에 Google 계정 로그인 → 오늘의 세트 오답 제출 → 같은 세션 JWT로 `POST /ai/diff-explain`·`POST /ai/explain-error` 모두 200, `promptVersion: 2`. 웹 시트는 SQL 선택지 오류 화면에서만 열려 화면 조작 대신 API를 직접 호출했다.

## 교훈
(원본에 없음, 볼트 정리) "일시적으로 사용 불가" 같은 대체 응답만 계속 나오면 장애가 아니라 미구현(`TODO` 예외)일 수 있다 — 서버 로그에 하위 서버 호출이 있는지부터 본다.
