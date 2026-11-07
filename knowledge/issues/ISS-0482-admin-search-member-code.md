---
type: issue
id: ISS-0482
created: 2026-11-07
topics: [admin, auth-member]
symptoms: ["관리자 전역 검색 회원 번호 못 찾음", "PQL- 검색", "GET /admin/search 500", "operator does not exist: uuid ~~ text", "as(String.class) SQL 형변환 없음", AdminGlobalSearchService, MemberSpecification, MemberCode]
root_cause: "관리자 전역 검색이 UUID 전체와 닉네임만 받았고, 처음 넣은 UUID 앞자리 비교는 JPA as(String.class) 가 SQL 형변환을 만들지 않아 uuid LIKE text 로 운영 500"
status: resolved
resolution: "[[ISS-0482-admin-search-member-code-report]]"
related: ["[[ISS-0481-app-settings-member-code-footer]]", "[[ISS-0483-admin-search-email]]", "[[ISS-0476-account-login-method-icon-email-avatar]]"]
source: "_sources/issues/ISS-0482-admin-search-member-code.md"
---

# ISS-0482: 관리자 전역 검색에서 회원 번호(PQL-)로 회원 찾기

GitHub #929 (https://github.com/Twin-Fang/passQL/issues/929).

## 증상
- 웹·앱 설정은 회원 번호(`PQL-` + UUID 앞 8자리)를 문의용으로 안내하는데, 관리자 전역 검색은 UUID 전체와 닉네임만 받아 그 값으로 회원을 찾을 수 없었다.
- 첫 배포(PR #930) 뒤 운영에서 회원 번호 검색이 500: `ERROR: operator does not exist: uuid ~~ text`.

## 재현 조건
관리자 전역 검색 `/admin/search?q=PQL-XXXXXXXX`.

## 조사 기록
- 2026-11-07: 회원 번호 공통 지점 `MemberCode`(만들기·읽기), 검색 조건 UUID 앞자리, 전역 검색 연결 (PR #930, 배포 1.92).
- 2026-11-07: 운영 500. 서버 로그(요청 ID)로 원인 확인: Hibernate 의 `root.get("memberUuid").as(String.class)` 가 SQL CAST 를 만들지 않음.
- 2026-11-07: `cb.function("text", ...)` 로 `text(member_uuid)` 명시 변환 (PR #932, 배포 1.92.1). 운영 Postgres 읽기 전용으로 같은 조건 1명 일치 확인.

## 근본 원인
기능 없음(검색 대상에 회원 번호가 없었음) + 구현 결함(JPA `as()` 가 SQL 형변환이 아님).
