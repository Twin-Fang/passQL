---
type: issue
id: ISS-0146
created: 2026-04-18
topics: [auth-member, security]
symptoms: ["anyRequest().permitAll()", "인증 없음", "memberUuid 쿼리 파라미터", createAnonymous, "GET /api/members/me", "소셜 로그인 없음", "/admin/** 권한 분리 없음"]
root_cause: "`SecurityConfig`가 `anyRequest().permitAll()`이고 회원 식별을 쿼리 파라미터 `memberUuid`에 의존, 익명 가입만 존재"
status: resolved
resolution: "[[ISS-0146-oauth-jwt-auth-system-report]]"
related: ["[[DEC-0080-firebase-oauth-own-jwt-no-anonymous]]"]
source: "https://github.com/Twin-Fang/passQL/issues/271"
---

# ISS-0146: 서버에 인증이 전혀 없고 익명 가입만 가능

GitHub #271 (원본: 이슈 본문과 리포트 댓글).

## 증상
- `SecurityConfig`가 `anyRequest().permitAll()` — 인증 없음.
- `MemberController`의 `GET /api/members/me`가 `memberUuid`를 쿼리 파라미터로 받아 인증 없이 동작.
- 익명 회원(`createAnonymous`)으로만 가입 가능, 소셜 로그인 없음.
- 관리자 페이지(`/admin/**`) 권한 분리가 인프라 레벨에만 의존.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-18: 설계 문서 `docs/superpowers/specs/2026-04-18-auth-design.md`.

## 근본 원인
인증 체계 미구현.
