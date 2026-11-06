---
type: completion-report
id: ISS-0464
created: 2026-11-07
topics: [admin, ai]
status: resolved
resolves: "[[ISS-0464-admin-prompt-key-single-source]]"
related: ["[[DEC-0265-prompt-key-enum-single-source]]"]
source: "_sources/issues/ISS-0464-admin-prompt-key-single-source-report.md"
---

# ISS-0464 완료 리포트: 프롬프트 키 단일 원본 `PromptKey`, 수정 시 키 고정

GitHub #875 리포트 기준 (2026-11-07). 운영 배포 릴리스 #882.

## 해결 방법
- `PromptKey` enum 에 코드가 읽는 키 9개(`explain_error`, `diff_explain`, `ai_comment`, `ai_analysis_stats`, `generate_choice_set` 계열 4개, `generate_question_full`)를 모음. 9개 서비스가 이 원본을 쓰고 `getActivePrompt` 인자도 `PromptKey` 타입 — [[DEC-0265-prompt-key-enum-single-source]].
- 수정 폼은 키를 읽기 전용으로 표시, 서버 `PromptService.update` 는 요청 키를 무시하고 기존 키 유지 + 경고 로그.
- 등록 폼은 `PromptKey` 목록 + DB 에만 있는 옛 키(`similar`, `ai_comment_stats`)를 "코드에서 읽지 않는 키"로 표시.
- 규칙 `server-prompt-key-single-source` 추가 (동결 목록 비어 있음).

## 검증
- `./gradlew build` 통과, 테스트 86개 실패 0 (키 유지 테스트 포함), 동결 규칙 11개 새 위반 0.

## 근본 원인 (확정)
키 원본 부재 + 수정 경로의 키 변경 허용.

## 재발 방지
- 키는 타입(`PromptKey`)으로 강제, 수정 경로에서 키 불변. 화면 실수가 다시 생겨도 서버가 막는다.

## 알고 남긴 것
- 같은 유형 버그: 문제 등록의 선택지 정책 목록에 `CURATED_ONLY`, `RESULT_MATCH` 누락, 설정 카테고리 필터 누락 > GitHub #879.
- 이후 #862 가 키 `ai_analysis_session` 을 추가 ([[ISS-0460-ai-analysis-forecast-concept-links-report]]). 이 리포트 시점 키 수는 9개.

## 교훈
화면의 선택 목록을 하드코딩하면 코드가 쓰는 값과 반드시 어긋난다. 목록은 코드 원본(enum)에서 만들고, 식별자 필드는 수정 경로에서 바꾸지 못하게 한다.
