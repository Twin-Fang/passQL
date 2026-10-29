---
type: completion-report
id: ISS-0276
created: 2026-10-15
topics: [security, auth-member]
status: resolved
resolves: "[[ISS-0276-suspended-member-blocked-only-in-getme]]"
related: ["[[DEC-0126-suspended-member-common-filter]]", "[[ISS-0290-app-settings-errors-suspension-notice]]"]
source: "https://github.com/Twin-Fang/passQL/issues/470"
---

# ISS-0276 완료 리포트: JWT 인증 뒤 `SuspendedMemberBlockingFilter`로 제재 회원 API 403 차단

GitHub #470 구현 보고서 댓글 기준 (1차 통합 main `0bc1ed5`, 서버 0.11.0).

## 해결 방법
- `SuspendedMemberBlockingFilter`를 JWT 인증 바로 뒤에 추가: 제재 중 회원의 회원 API를 403 `MEMBER_SUSPENDED`로 차단.
- 차단하지 않는 요청: `/api/auth/**`(재발급 후 getMe의 403으로 앱이 제재 안내를 띄우는 흐름 유지), `/api/meta/**`, `/actuator/**`, `DELETE /api/members/me`(제재 중에도 탈퇴 가능).
- `MemberSuspensionService`: 회원별 판정 5초 캐시, 관리자가 제재·해제하면 해당 회원 캐시 즉시 삭제.
- 앱(GitHub #484): 403 `MEMBER_SUSPENDED` 수신 시 안내 후 로그아웃.
- 검증: `SuspendedMemberBlockingFilterTest` 3건, ArchUnit 4건, ErrorFormat 5건. 서버 전체 96개 중 95개 통과(실패 `ChoiceSetEntityIntegrationTest.quizSession_저장과_조회`는 main에서도 실패하던 dev DB 외래키 문제). Spring `38707438043`, AI `38707437899`, Vercel `38707437743` 성공.

## 근본 원인 (확정)
제재 검사가 `MemberService.getMe` 한 곳에만 있었다.

## 재발 방지
공통 필터 한 곳에서 검사. 주의(원본): 제재 기간이 끝난 직후 최대 5초 동안 차단이 남을 수 있다(캐시).

## 교훈
(원본에 없음, 볼트 정리) 권한·상태 검사가 특정 서비스 메서드에만 있으면 다른 API로 우회된다. 공통 필터에 두었는지부터 본다.
