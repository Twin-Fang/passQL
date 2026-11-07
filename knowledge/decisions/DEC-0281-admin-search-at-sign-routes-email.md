---
type: decision
id: DEC-0281
created: 2026-11-07
reviewed: null
topics: [admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0483-admin-search-email]]", "[[ISS-0482-admin-search-member-code]]"]
---

# DEC-0281: 관리자 전역 검색은 칸 하나로, 검색어 모양으로 대상을 고른다 (UUID > 회원 번호 > `@` 이메일 > 닉네임)

## 문제 정의 (Context)
문의 대응 때 사용자가 알려 주는 값이 UUID, 회원 번호, 이메일, 닉네임 중 하나다 (#929, #934).

## 결정 (Decision)
관리자 전역 검색은 입력 칸 하나를 유지하고 검색어 모양으로 대상을 고른다: UUID 형식이면 회원·문제 정확 일치, `PQL-` + 16진수 8자리면 회원 UUID 앞자리 일치, `@` 가 들어 있으면 이메일 일부 일치, 그 밖은 닉네임 일부 일치. 결과 1건이면 바로 상세로 간다.

## 검토한 대안 (Alternatives)
- 별도 검색 모드 선택: 완료 리포트에 "별도 검색 모드 선택 없이 칸 하나로 처리"라고만 적혀 있음. 그 밖의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 닉네임은 한글·영문·숫자 2~10자만 허용(`NicknameChangeRequest`)이라 `@` 가 든 검색어는 닉네임일 수 없어 겹치지 않는다.
- 이메일은 관리자 회원 상세에 이미 보이는 값이라 검색으로 새로 드러나는 정보가 없다.

**부정**
- 이메일 일부 일치는 인덱스를 타지 않는다(지금 규모는 문제없음).
- 회원 번호 앞 8자리가 겹치면 후보 여러 명이 나온다.

## 영향 범위 (Scope)
`AdminGlobalSearchService`, `MemberSearchCondition`, `MemberSpecification`, 관리자 `layout.html`·`search-results.html` 안내 문구.

## 출처 (References)
- GitHub #929, #934 완료 리포트 댓글 (2026-11-07)
