---
type: issue
id: ISS-0483
created: 2026-11-07
topics: [admin, auth-member]
symptoms: ["관리자 전역 검색 이메일로 못 찾음", "이메일 필수 아님", "문의 메일 주소로 회원 찾기", AdminGlobalSearchService, MemberSpecification.emailContains]
root_cause: "이메일은 선택 정보라(운영 41명 중 3명) 전역 검색 대상이 아니었다"
status: resolved
resolution: "[[ISS-0483-admin-search-email-report]]"
related: ["[[ISS-0482-admin-search-member-code]]", "[[DEC-0281-admin-search-at-sign-routes-email]]", "[[ISS-0476-account-login-method-icon-email-avatar]]"]
source: "_sources/issues/ISS-0483-admin-search-email.md"
---

# ISS-0483: 관리자 전역 검색에서 이메일로 회원 찾기

GitHub #934 (https://github.com/Twin-Fang/passQL/issues/934).

## 증상
관리자 전역 검색은 UUID, 회원 번호(#929), 닉네임만 받는다. 카카오·네이버·GitHub 이메일 동의(#908)를 켜면 이메일 있는 회원이 늘어나는데, 문의 메일 주소로 회원을 찾을 방법이 없다.

## 재현 조건
관리자 전역 검색에 이메일 입력.

## 조사 기록
- 2026-11-07: 사용자 질문("이 서비스 이메일이 필수요소가 아니였어?")으로 확인: 회원 기본키는 `member_uuid`, 로그인은 (`auth_provider`, `provider_user_id`)로 찾고 이메일은 nullable. 운영 제공자별 이메일 보유: Google 일부만, 나머지 0.
- 2026-11-07: `@` 포함 검색어 > 이메일 일부 일치 (PR #935, 배포 1.93.0).

## 근본 원인
이메일을 검색 대상으로 둔 적이 없었다(필수 정보가 아님).
