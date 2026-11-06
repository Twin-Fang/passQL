---
type: decision
id: DEC-0270
created: 2026-11-07
reviewed: null
topics: [auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0468-web-audit-cross-tab-reissue-logout]]", "[[ISS-0468-web-audit-cross-tab-reissue-logout-report]]", "[[DEC-0269-web-reissue-single-across-tabs]]", "[[DEC-0144-per-device-refresh-token-reuse-revoke]]"]
---

# DEC-0270: 웹 재발급 실패는 401 또는 회원 없음(`MEMBER_NOT_FOUND`)일 때만 로그아웃하고, 네트워크 오류·타임아웃·5xx 는 세션을 유지한다

## 문제 정의 (Context)
웹은 재발급이 네트워크 오류·타임아웃·5xx 로 실패해도 강제 로그아웃했다. 일시 오류로 정상 세션이 끊겼다 (GitHub #881, [[ISS-0468-web-audit-cross-tab-reissue-logout]]).

## 결정 (Decision)
- **세션 종료로 보는 재발급 실패:** HTTP 401 전부(무효·만료·재사용 판정) + 회원 없음 `MEMBER_NOT_FOUND`(탈퇴) > 로그아웃 후 로그인 화면.
- **일시 오류:** 네트워크 오류·타임아웃·5xx 등 그 외 > 세션 유지, 원래 오류만 호출부로 전달.
- 재발급 수단(refresh token)이 없으면 바로 로그아웃 (#398 기존 동작 유지).
- 판정은 `api/client.ts` `isSessionEndingReissueError` 한 곳, apiFetch·SSE 공통.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문 「예상 동작」은 "401·INVALID_TOKEN 일 때만 로그아웃", 구현은 401 전부 + `MEMBER_NOT_FOUND`.)

## 결과 (Consequences)
**긍정**
- 서버 일시 장애·네트워크 끊김에 세션이 유지된다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
웹 `client/src/api/client.ts` (`SESSION_ENDING_REISSUE_ERROR_CODES`, `resolveAccessTokenAfterUnauthorized`). 앱 재발급 인터셉터의 로그아웃 조건은 원본에 언급 없음.

## 출처 (References)
- GitHub #881 이슈 본문·리포트 댓글 (2026-11-07)
- W4 충돌 검사: 재발급 실패 시 로그아웃 조건을 정한 활성 결정 없음
