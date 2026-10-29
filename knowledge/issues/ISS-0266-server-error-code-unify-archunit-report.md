---
type: completion-report
id: ISS-0266
created: 2026-10-15
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0266-server-error-code-unify-archunit]]"
related: ["[[DEC-0118-single-source-commonization-rules]]"]
source: "https://github.com/Twin-Fang/passQL/issues/460"
---

# ISS-0266 완료 리포트: `ErrorResponse.of(ErrorCode)` 단일 응답, 계층 정리, ArchUnit 강제

GitHub #460 구현 보고서(2026-10-15) 기준.

## 해결 방법
- 오류 응답: `ErrorResponse.of(ErrorCode)` 하나로만. ErrorCode 추가(`ILLEGAL_ARGUMENT`, `VALIDATION_ERROR`, `MESSAGE_NOT_READABLE`, `MISSING_PARAMETER`, `TYPE_MISMATCH`, `DATA_INTEGRITY_VIOLATION`, `GENERATION_FAILED` 등). 404는 `RESOURCE_NOT_FOUND`, 잘못된 enum 요청값은 `INVALID_INPUT_VALUE`. SSE 오류 이벤트는 `errorCode`와 `code`에 같은 값(앱은 `errorCode` 우선). 관리자 API 오류도 `CustomException(ErrorCode)`.
- 계층: 컨트롤러·초기화 코드의 Repository 직접 사용 제거, `ChoiceGenerationStreamService` 분리.
- 공통 지점: `AppSettingKeys`, `AdminPageRequest`, `TextPreview`, `UuidUtils`, `fromRequestValue`.
- 삭제: `question-form.html`, 레거시 SSR `quiz/*` 템플릿과 `QuizController`. 관리자 사이드바 로고 테마별 전환.
- 규칙 테스트: `ArchitectureRuleTest`(표현 계층 Repository 의존 금지 등), `ErrorFormat` 테스트. `server/CLAUDE.md`를 실제 구조(모듈 8개)에 맞게 갱신.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 원본: 새 오류는 ErrorCode enum에 추가하고 `ErrorResponse.of`로만 응답한다. Map이나 문자열로 직접 만들면 ArchUnit·ErrorFormat 테스트가 실패한다. 앱 오류 코드 매핑(#461)은 enum 이름에 묶여 있다.
- 검증: 서버 테스트 78개 중 77개 통과(`ChoiceSetEntityIntegrationTest.quizSession_저장과_조회`는 origin/main에서도 실패, dev DB 외래키), 운영 run `38697240692`, 인증 없는 API → 401 `{"errorCode":"UNAUTHORIZED",...}`.
- 남은 일(원본): 300줄 넘는 서비스 분리, 다른 도메인 Repository 직접 사용, Java Gemini 키가 yml에서만 읽히는 문제.

## 교훈
원본 재발 방지 문장과 같음.
