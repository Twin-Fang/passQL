---
type: issue
id: ISS-0276
created: 2026-10-15
topics: [security, auth-member]
symptoms: [제재 회원, SUSPENDED, MEMBER_SUSPENDED, "getMe에서만 검사", "토큰 가진 제재 회원 API 사용", 인증 필터]
root_cause: "제재 여부를 `MemberService.getMe`에서만 검사해, 이미 토큰을 가진 제재 회원이 다른 API를 계속 쓸 수 있었다"
status: resolved
resolution: "[[ISS-0276-suspended-member-blocked-only-in-getme-report]]"
related: ["[[DEC-0126-suspended-member-common-filter]]", "[[ISS-0290-app-settings-errors-suspension-notice]]"]
source: "https://github.com/Twin-Fang/passQL/issues/470"
---

# ISS-0276: 제재 회원 차단이 getMe에서만 동작

GitHub #470 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
`MemberService.java:53`에서만 제재 여부를 검사하고 인증 필터에는 SUSPENDED 확인이 없다. 이미 토큰을 가진 제재 회원이 제출, 신고 등 다른 API를 계속 쓸 수 있다.

## 재현 조건
토큰을 가진 상태에서 제재된 회원이 `getMe` 외의 회원 API(제출, 신고 등)를 호출.

## 조사 기록
- 2026-10-15: 이슈 본문의 예상 동작 — 인증 필터 등 공통 지점 한 곳에서 검사, 모든 회원 API에서 403 `MEMBER_SUSPENDED`, 앱은 안내 화면 후 로그아웃(GitHub #484와 연계).

## 근본 원인
frontmatter `root_cause`와 같음.
