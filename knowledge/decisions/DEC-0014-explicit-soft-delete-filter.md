---
type: decision
id: DEC-0014
created: 2026-04-07
reviewed: null
topics: [ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0009-member-domain-module-entity]]", "[[ISS-0009-member-domain-module-entity-report]]"]
---

# DEC-0014: 소프트 딜리트는 `@SQLDelete` 없이 `is_deleted` 컬럼 + `AndIsDeletedFalse` 메서드로 명시 필터링

## 문제 정의 (Context)
GitHub #6에서 Member에 탈퇴·삭제를 대비한 소프트 딜리트 베이스(`SoftDeletableBaseEntity`)를 만들었다.

## 결정 (Decision)
`@SQLDelete` / `@SQLRestriction`을 쓰지 않는다. `SoftDeletableBaseEntity`의 `is_deleted` 컬럼과 Spring Data JPA 메서드 이름(`AndIsDeletedFalse` 접미)으로 명시적으로 필터링한다 (예: `findByMemberUuidAndIsDeletedFalse`, `existsByNicknameAndIsDeletedFalse`).

## 검토한 대안 (Alternatives)
- `@SQLDelete` / `@SQLRestriction`: 리포트는 bulk DELETE/native query 우회, 글로벌 필터로 인한 어드민 조회 곤란, PK 컬럼 하드코딩 문제 등 제약이 크다고 판단해 쓰지 않았다고 적었다.

## 결과 (Consequences)
**긍정**
- 리포트: 필요 시 관리자 쿼리에서 필터를 쉽게 제거할 수 있다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`PQL-Common` `entity/SoftDeletableBaseEntity.java`, `MemberRepository` 등 소프트 딜리트 엔티티의 리포지토리 메서드.

## 출처 (References)
- GitHub #6 `## 개요` 리포트 댓글 「Soft Delete 전략 (@SQLDelete 미사용)」 (2026-04-07)
