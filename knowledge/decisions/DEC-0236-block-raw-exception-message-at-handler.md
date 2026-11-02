---
type: decision
id: DEC-0236
created: 2026-11-02
reviewed: null
topics: [dev-workflow, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0440-third-architecture-audit-followup]]", "[[ISS-0440-third-architecture-audit-followup-report]]", "[[DEC-0013-single-custom-exception-error-code]]"]
---

# DEC-0236: `IllegalArgumentException` 원문은 전역 처리기에서 응답으로 내보내지 않고, 사용자용 문구는 `CustomException` + `ErrorCode` 로 던진다

## 문제 정의 (Context)
3차 감사(GitHub #789)에서 `GlobalExceptionHandler` 가 `IllegalArgumentException` 의 `e.getMessage()` 를 그대로 응답에 넣어 `No enum constant com.passql…`(패키지 이름), `Invalid UUID string` 이 공개 API 로 나가는 것을 확인했다. 10-29 감사에서 발생원 1곳을 고쳤지만 같은 원인이 다른 컨트롤러에 남아 있었다.

## 결정 (Decision)
- 전역 처리기는 `IllegalArgumentException` 에 대해 `ErrorCode.ILLEGAL_ARGUMENT` 기본 문구만 응답하고, 원문은 `LogValueSanitizer.toLogSafeText` 로 정리해 로그로만 남긴다.
- 사용자에게 보여 줄 문구가 필요한 곳은 `IllegalArgumentException` 대신 `CustomException(ErrorCode.XXX)` 을 던진다(관리자 화면 2곳 `MetaService` 전환).
- 사람에게 보여 주려고 만든 검증 사유(줄 번호 포함 섹션 파서 문구)는 예외 원문 대신 결과 값(`findFormatViolation()`)으로 돌려준다.
- 동결 규칙 `server-no-raw-exception-message` 가 응답으로 가는 `getMessage()` 형태를 잡는다.

## 검토한 대안 (Alternatives)
- 발생원(UUID·enum 파싱)만 하나씩 공통 지점으로 바꾸기: JDK·라이브러리 원문은 어디서든 다시 생겨 처리기에서 막지 않으면 재발한다는 이유로 처리기 차단을 함께 함(리포트 「왜 이렇게 했나」).
- 처리기에서 원문을 그대로 두고 메시지만 자르기: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 공개 API 응답에 내부 클래스·패키지 이름이 나가지 않는다.

**부정**
- 잘못된 enum·UUID 요청은 어떤 값이 틀렸는지 응답에서 알 수 없다(로그로만 확인). `ConceptLearningService` 저장 본문 형식 오류도 고정 문구가 된다.

## 영향 범위 (Scope)
`PQL-Common` `exception/GlobalExceptionHandler.java`, `util/LogValueSanitizer.java`, `MetaService`, `ConceptDetailSectionParser`, `ConceptAdminService`, `ConceptBundleValidator`, `docs/architecture/rules/server-no-raw-exception-message.rule`. [[DEC-0013-single-custom-exception-error-code]] 의 "내부 예외 메시지를 응답에 섞지 않는다"를 처리기 수준에서 강제하는 구체화이며 대체하지 않는다.

## 출처 (References)
- GitHub #789 리포트 댓글 「왜 이렇게 했나」 (2026-11-02)
- PR #790 커밋 `5c2a1afe`
