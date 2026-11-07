---
type: completion-report
id: ISS-0483
created: 2026-11-07
topics: [admin, auth-member]
status: resolved
resolves: "[[ISS-0483-admin-search-email]]"
related: ["[[DEC-0281-admin-search-at-sign-routes-email]]"]
source: "_sources/issues/ISS-0483-admin-search-email.md"
---

# ISS-0483 완료 리포트: 관리자 전역 검색 이메일 지원

## 해결 방법
- `MemberSearchCondition.email`, `MemberSpecification.emailContains`: 이메일 일부 일치(대소문자 무관, 이메일 없는 회원은 제외).
- `AdminGlobalSearchService`: 검색 순서 UUID > 회원 번호(PQL-) > `@` 포함이면 이메일 > 닉네임. 검색 칸·결과 없음 안내에 이메일.
- 운영 실측: `@GMAIL`(대문자) > Google 가입 회원 3명, 운영 DB 의 gmail.com 이메일 회원 수(3)와 같음. 결과 화면은 회원 정보가 보여 캡처를 올리지 않음.

## 근본 원인 (확정)
이메일은 선택 정보라 검색 경로가 없었다.

## 재발 방지
검색 경로 선택 규칙은 [[DEC-0281-admin-search-at-sign-routes-email]].

## 교훈
`lower(email) like '%…%'` 는 인덱스를 타지 않는다. 지금 규모(수십 명)는 문제없고, 회원이 수만 명이 되면 정확 일치나 인덱스를 검토한다.
