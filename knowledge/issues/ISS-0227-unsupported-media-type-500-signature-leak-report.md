---
type: completion-report
id: ISS-0227
created: 2026-10-07
topics: [security, ops-infra]
status: resolved
resolves: "[[ISS-0227-unsupported-media-type-500-signature-leak]]"
related: ["[[DEC-0102-fixed-error-messages-detail-in-logs]]"]
source: "https://github.com/Twin-Fang/passQL/issues/393"
---

# ISS-0227 완료 리포트: 미지원 Content-Type은 415, 본문 오류는 고정 문구

GitHub #393 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
완료 댓글은 운영 실측 결과만 적었다. 코드 변경 내용(파일·메서드)은 원본에 적혀 있지 않다.

## 근본 원인 (확정)
이슈 본문 기준: 미지원 Content-Type 미처리, 메시지에 `e.getMessage()` 부착.

## 재발 방지
운영 실측(수정 후):
```
{"errorCode":"UNSUPPORTED_MEDIA_TYPE","message":"지원하지 않는 미디어 타입입니다."} HTTP 415
{"errorCode":"MESSAGE_NOT_READABLE","message":"요청 본문을 읽을 수 없습니다. 형식을 확인해주세요"} HTTP 400
```
수정 전: 500 `INTERNAL_SERVER_ERROR` / 메시지에 `com.passql.web.controller.AuthController.login(...)` 노출.

## 교훈
(원본에 없음, 볼트 정리) 예외 메시지 원문을 응답에 붙이면 내부 구조가 새어 나간다. 오류 응답을 볼 때 `message`에 패키지명이 보이는지부터 확인한다.
