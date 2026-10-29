---
type: decision
id: DEC-0013
created: 2026-04-07
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0009-member-domain-module-entity]]", "[[ISS-0009-member-domain-module-entity-report]]", "[[ISS-0029-realtime-ai-choice-set-prefetch]]"]
---

# DEC-0013: 도메인별 예외 클래스 없이 전역 `CustomException` 1개 + 중앙 `ErrorCode` enum

## 문제 정의 (Context)
GitHub #6에서 Member 도메인의 에러를 추가하면서 서버 예외 체계를 정리했다.

## 결정 (Decision)
도메인별 예외 클래스를 만들지 않고 `CustomException` 한 개와 중앙 `ErrorCode` enum으로 통일한다. 기본 사용은 `throw new CustomException(ErrorCode.MEMBER_NOT_FOUND)`이고 추가 디버깅 정보가 필요할 때만 detail/cause 오버로드를 쓴다. 사용자 응답에 내부 식별자(`memberUuid`)나 내부 예외 메시지가 섞이지 않도록 서비스 레이어는 detail을 붙이지 않고 `log.warn/error`로만 남긴다. `ErrorCodeBuilder.java`, `ErrorMessageTemplate.java`는 제거했다.
GitHub #39 이슈 본문도 "모든 에러는 `CustomException(ErrorCode.XXX)` 단일 패턴으로 통일"을 다시 적었다.

## 검토한 대안 (Alternatives)
- 도메인별 예외 클래스: 만들지 않기로 함. 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`PQL-Common` `exception/CustomException.java`, `exception/ErrorResponse.java`, `exception/constant/ErrorCode.java`, `exception/GlobalExceptionHandler.java`, 모든 서비스 레이어.

## 출처 (References)
- GitHub #6 `## 개요` 리포트 댓글 「단일 전역 예외 + 중앙 ErrorCode」 (2026-04-07)
- GitHub #39 이슈 본문 「에러 처리 통일」
