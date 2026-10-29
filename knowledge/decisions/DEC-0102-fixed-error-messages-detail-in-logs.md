---
type: decision
id: DEC-0102
created: 2026-10-07
reviewed: null
topics: [security, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0227-unsupported-media-type-500-signature-leak]]", "[[ISS-0227-unsupported-media-type-500-signature-leak-report]]", "[[DEC-0106-unified-error-body-for-security-errors]]"]
---

# DEC-0102: API 오류 메시지는 고정 문구만 내보내고 상세는 서버 로그에만 남긴다

GitHub #393 (원본: 이슈 본문 「예상 동작」과 완료 댓글).

## 문제 정의 (Context)
본문이 없거나 깨진 요청의 오류 메시지에 `GlobalExceptionHandler`가 `e.getMessage()`를 붙여 내부 클래스·메서드 시그니처가 노출됐다. 미지원 `Content-Type`은 500으로 응답됐다.

## 결정 (Decision)
- 오류 메시지는 고정 문구만 내보내고 상세는 서버 로그에만 남긴다.
- 미지원 Content-Type → 415 `UNSUPPORTED_MEDIA_TYPE`, 미지원 메서드 → 405.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 응답에 내부 시그니처가 나가지 않는다 (운영 실측 `"요청 본문을 읽을 수 없습니다. 형식을 확인해주세요"`).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
서버 `GlobalExceptionHandler` (원본에 적힌 위치). 그 밖의 변경 파일은 원본에 적혀 있지 않다.

## 출처 (References)
- GitHub #393 이슈 본문 「예상 동작」, 완료 댓글(PR #407, v0.0.247)
- [[ISS-0227-unsupported-media-type-500-signature-leak]]
