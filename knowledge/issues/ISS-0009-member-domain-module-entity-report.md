---
type: completion-report
id: ISS-0009
created: 2026-04-07
topics: [auth-member]
status: resolved
resolves: "[[ISS-0009-member-domain-module-entity]]"
related: ["[[DEC-0012-nickname-via-suh-random-engine]]", "[[DEC-0013-single-custom-exception-error-code]]", "[[DEC-0014-explicit-soft-delete-filter]]"]
source: "https://github.com/Twin-Fang/passQL/issues/6"
---

# ISS-0009 완료 리포트: `PQL-Domain-Member` 분리, 확장형 Member Entity, 닉네임 3단계 폴백

GitHub #6 `## 개요` 리포트 댓글(2026-04-07) 기준. 코드 리뷰의 Critical/Major/Minor 이슈를 반영한 최종 상태라고 적었다.

## 해결 방법
- 모듈: `PQL-Domain-Member` include, Suh-Nexus Maven 저장소 등록(`allowInsecureProtocol`), `suh-random-engine:1.1.0` 의존성.
- 공통: `SoftDeletableBaseEntity`(`is_deleted`/`deleted_at`/`deleted_by`), 전역 `CustomException` + 중앙 `ErrorCode`에 `MEMBER_NOT_FOUND`(404)·`MEMBER_ALREADY_WITHDRAWN`(410)·`NICKNAME_DUPLICATE`(409)·`NICKNAME_GENERATION_FAILED`(500) 추가, `DataIntegrityViolationException` 409 핸들러, `NicknameGenerator`(DB 비의존, `Predicate<String>` 중복 체커). `ErrorCodeBuilder.java`·`ErrorMessageTemplate.java` 제거.
- 도메인: `MemberRole`(`USER / TEST / ADMIN / SUPER_ADMIN`), `MemberStatus`(`ACTIVE / DORMANT / SUSPENDED / WITHDRAWN`), `AuthProvider`(`ANONYMOUS / GOOGLE / KAKAO / NAVER / APPLE / GITHUB`), UUID PK `Member`, `is_test_account` 플래그.
- API: `POST /api/members/register`, `GET /api/members/me?memberUuid=`, `POST /api/members/me/regenerate-nickname?memberUuid=`.
- Flyway: `V0_0_16__add_member_table.sql` — 인덱스를 `CREATE TABLE` 절 안에 정의(MySQL은 단독 `CREATE INDEX`에 `IF NOT EXISTS` 미지원).
- 닉네임 race: `saveAndFlush` + `DataIntegrityViolationException` catch + 최대 3회 재시도. 폴백은 `simpleNickname()` 3회 → `nicknameWithNumber()` 3회 → `nicknameWithUuid()` 1회 → `NICKNAME_GENERATION_FAILED`.
- `last_seen_at`: `LAST_SEEN_THROTTLE_MINUTES = 5`, 5분 지났을 때만 갱신.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
리포트 주의사항:
- 내부망 특성상 `SuhRandomKit` 빌더 API를 런타임 확인하지 못했다 — 최초 구동 시 v1.1.0 시그니처 검증 필요.
- `@RequestParam memberUuid` 노출은 익명 등록 전제의 임시 방식 — Spring Security 도입 후 `@AuthenticationPrincipal`로 대체해야 한다.
- 단위 테스트 미포함(내부망 제약). 닉네임 폴백·재시도는 후속 PR에서 모킹 기반 커버 필요.
- 후속: OAuth, 어드민 권한 API, 탈퇴 + 개인정보 파기, `user_uuid → member_uuid` 명칭 통일.

## 교훈
원본에 적혀 있지 않다.
