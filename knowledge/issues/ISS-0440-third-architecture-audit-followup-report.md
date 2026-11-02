---
type: completion-report
id: ISS-0440
created: 2026-11-02
topics: [dev-workflow, security]
status: resolved
resolves: "[[ISS-0440-third-architecture-audit-followup]]"
related: ["[[ISS-0440-third-architecture-audit-followup]]", "[[DEC-0236-block-raw-exception-message-at-handler]]", "[[ISS-0433-second-architecture-audit-followup-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/789"
---

# ISS-0440 완료 리포트: 예외 원문 응답 차단, 공통 지점 미사용 사본 정리, 동결 규칙 확장

## 해결 방법
PR #790, 87개 파일.
- 서버: `IllegalArgumentException` 은 `ILLEGAL_ARGUMENT` 기본 문구만 응답하고 원문은 정리 후 로그로만([[DEC-0236-block-raw-exception-message-at-handler]]). 관리자용 한국어 예외 2곳(`MetaService`)은 `CustomException(CONCEPT_NOT_FOUND)`, 섹션 파서는 `findFormatViolation()` 으로 사유를 결과로 반환. UUID·SHA-256·enum 변환은 `UuidUtils`·`Sha256Hex`·`fromRequestValue`/`RequestEnumParser`, 로그 값 정리 3곳은 새 `LogValueSanitizer`(식별자용·문장용).
- 앱: `debugPrint` 49건 > `AppLogger`(디버그 빌드만 콘솔 동시 출력), catch 3곳에 `reportIfUnexpectedFailure`, 투명도 토큰 `PassqlOpacity`.
- 웹: `types/api.ts` 에 `ApiSchemas[...]` 별칭 추가 후 손작성 타입 삭제, `RECOMMENDATIONS_QUERY_KEY`·`MEMBER_QUERY_KEY`.
- AI: 로그 31건 영어 기능 접두사로, `LOGGED_PAYLOAD_MAXIMUM_LENGTH` 삭제.
- 규칙 문서: 삭제된 테스트 참조와 코드와 어긋난 설명 정정(server·app·client·ai CLAUDE.md, Design.md, api-guide.md, AGENTS.md).

응답이 달라진 곳: 잘못된 enum·UUID 는 고정 문구, `MetaService` 2곳 400 > 404, `AiController` `questionUuid` 누락 500 > 400.

검증: server test 53, client lint·test 11·build·gen:api 차이 없음, app analyze 0·test 94, ai pytest 48, 동결 규칙 11개 위반 0.

## 근본 원인 (확정)
동결 규칙 범위가 좁았다(`server-no-raw-exception-message` 는 `": " + e.getMessage()` 한 형태, `client-no-handwritten-api-type` 은 `types/api.ts` 한 파일). #680 에서 테스트를 지울 때 그 테스트를 근거로 든 규칙 문서를 갱신하지 않았다.

## 재발 방지
- `server-no-raw-exception-message` 패턴 확장(응답으로 가는 `getMessage()` 전반, 허용 목록 1 > 0)
- `client-no-handwritten-api-type` paths 에 `client/src/api/` 추가
- 앱 `logging_rules_test.dart`: `app/lib` 의 `debugPrint(` 금지 (예외: `app_logger.dart`, 디버그 전용 `debug_log_interceptor.dart`)
- `ai-no-korean-log` 동결 규칙(허용 목록 0줄) + 검사 테스트
- 범위 밖으로 남긴 것: 요청 DTO, 개념 결과 화면 분할, 브랜드 강조색 검사, `plan` enum → GitHub #791

## 교훈
- 동결 규칙을 만들 때 처음 본 한 형태가 아니라 같은 원인의 다른 모양(다른 파일·처리기)까지 잡는지 수정 전 코드로 확인한다.
- 테스트를 지우는 커밋에서는 그 테스트 이름을 `grep` 해 규칙 문서·CLAUDE.md 의 언급을 함께 고친다.
