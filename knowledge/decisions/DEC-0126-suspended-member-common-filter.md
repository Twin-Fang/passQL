---
type: decision
id: DEC-0126
created: 2026-10-15
reviewed: null
topics: [security, auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0276-suspended-member-blocked-only-in-getme]]", "[[ISS-0290-app-settings-errors-suspension-notice]]"]
---

# DEC-0126: 제재 회원 차단은 JWT 인증 뒤 공통 필터 한 곳에서, 인증·메타·탈퇴 요청은 예외

## 문제 정의 (Context)
제재 여부를 `MemberService.getMe`에서만 검사해 토큰을 가진 제재 회원이 다른 API를 계속 쓸 수 있었다 (GitHub #470).

## 결정 (Decision)
- `SuspendedMemberBlockingFilter`(JWT 인증 바로 뒤)가 제재 중 회원의 회원 API를 403 `MEMBER_SUSPENDED`로 막는다.
- 예외: `/api/auth/**`, `/api/meta/**`, `/actuator/**`, `DELETE /api/members/me`(제재 중에도 탈퇴 가능).
- 판정은 회원별 5초 캐시, 관리자가 제재·해제하면 해당 회원 캐시 즉시 삭제.
- 앱은 403 `MEMBER_SUSPENDED`를 받으면 안내 후 로그아웃(GitHub #484).

## 검토한 대안 (Alternatives)
논의 기록 없음. (원본이 밝힌 예외 이유: `/api/auth/**`는 재발급 후 getMe의 403으로 앱이 제재 안내를 띄우는 흐름을 유지하려고 열어 둔다.)

## 결과 (Consequences)
**긍정**
- 모든 회원 API에서 제재 상태가 일관되게 적용된다.

**부정**
- 제재 기간이 끝난 직후 최대 5초 동안 차단이 남을 수 있다(캐시).

## 영향 범위 (Scope)
서버 보안 필터 체인(`SuspendedMemberBlockingFilter`), `MemberSuspensionService`, 관리자 제재·해제 처리, 앱 `MemberSuspensionInterceptor`(GitHub #484).

## 출처 (References)
- GitHub #470 이슈 본문, 구현 보고서 댓글(2026-10-15)
- [[ISS-0276-suspended-member-blocked-only-in-getme]]
