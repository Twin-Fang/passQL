---
type: issue
id: ISS-0227
created: 2026-10-07
topics: [security, ops-infra]
symptoms: ["미지원 Content-Type 500", UNSUPPORTED_MEDIA_TYPE, MESSAGE_NOT_READABLE, "내부 시그니처 노출", GlobalExceptionHandler, "e.getMessage()"]
root_cause: "`GlobalExceptionHandler`가 미지원 Content-Type을 500으로 처리하고, 본문 오류 메시지에 `e.getMessage()`를 붙였다"
status: resolved
resolution: "[[ISS-0227-unsupported-media-type-500-signature-leak-report]]"
related: ["[[DEC-0102-fixed-error-messages-detail-in-logs]]"]
source: "https://github.com/Twin-Fang/passQL/issues/393"
---

# ISS-0227: 미지원 Content-Type이 500으로 응답되고 오류 메시지에 내부 시그니처 노출

GitHub #393 (원본: 이슈 본문과 완료 댓글).

## 증상
- 지원하지 않는 `Content-Type` 요청이 415가 아니라 500, 서버 로그에 ERROR와 스택트레이스.
- 본문이 없거나 JSON이 깨진 요청의 메시지에 내부 클래스·메서드 시그니처가 그대로 노출:
```
{"errorCode":"MESSAGE_NOT_READABLE","message":"요청 본문을 읽을 수 없습니다: Required request body is missing: public org.springframework.http.ResponseEntity<com.passql.member.auth.presentation.dto.response.LoginResponse> com.passql.web.controller.AuthController.login(com.passql.member.auth.presentation.dto.request.LoginRequest)"}
```

## 재현 조건
운영 E2E QA(2026-10-08, v0.0.245). `curl -X POST <API 서버>/api/auth/login -H 'Content-Type: text/plain' -d x` → 500. `-H 'Content-Type: application/json'`(본문 없음) → 시그니처 노출 400.

## 조사 기록
- 2026-10-07: `GlobalExceptionHandler`가 `e.getMessage()`를 붙임.

## 근본 원인
예외 처리기가 미지원 미디어 타입을 따로 처리하지 않았고, 사용자 메시지에 예외 원문을 붙였다.
