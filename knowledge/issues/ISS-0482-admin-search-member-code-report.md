---
type: completion-report
id: ISS-0482
created: 2026-11-07
topics: [admin, auth-member]
status: resolved
resolves: "[[ISS-0482-admin-search-member-code]]"
related: ["[[ISS-0483-admin-search-email]]"]
source: "_sources/issues/ISS-0482-admin-search-member-code.md"
---

# ISS-0482 완료 리포트: 관리자 전역 검색 회원 번호 지원

## 해결 방법
- `PQL-Common/.../util/MemberCode.java` (신규): `fromMemberUuid` UUID > `PQL-XXXXXXXX`, `parseUuidPrefix` 입력 > UUID 앞 8자리 소문자(대소문자·앞뒤 공백 무시, 형식 아님 > empty). `MemberMeResponse` 도 같은 곳을 씀(값 동일).
- `MemberSearchCondition.memberUuidPrefix`, `MemberSpecification.memberUuidStartsWith`: `text(member_uuid) like '<앞자리>%'`.
- `AdminGlobalSearchService`: UUID 형식 > 회원 번호 형식 > 닉네임 일부. 검색 칸 안내 문구에 회원 번호.
- 운영 실측: `pql-fd06966e`(소문자) > 회원 상세로 바로 이동, `PQL-00000000` > 결과 없음 안내.

## 근본 원인 (확정)
JPA Criteria `as(String.class)` 는 Hibernate 에서 SQL 형변환을 만들지 않는다. uuid 컬럼에 LIKE 를 걸면 Postgres 가 `uuid ~~ text` 연산자 없음으로 거부.

## 재발 방지
- 컬럼 형변환이 필요하면 `cb.function("text", String.class, ...)` 처럼 SQL 함수로 명시한다.
- 회원 번호는 앞 8자리라 이론상 겹칠 수 있어 결과가 여럿이면 목록으로 보여 준다.

## 교훈
JPA 쿼리를 바꾸면 테스트 DB 가 없어도 운영과 같은 Postgres 에 읽기 전용으로 같은 SQL 을 먼저 실행해 본다. 배포 뒤 500 은 관리자 모니터링의 요청 ID 로 서버 로그를 찾는다.
