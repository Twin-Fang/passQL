---
type: decision
id: DEC-0012
created: 2026-04-07
reviewed: null
topics: [auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0009-member-domain-module-entity]]", "[[ISS-0009-member-domain-module-entity-report]]", "[[ISS-0013-flyway-missing-tables-seed]]"]
---

# DEC-0012: 닉네임은 자체 단어 테이블 대신 `suh-random-engine` 라이브러리로 생성

## 문제 정의 (Context)
익명 회원에게 닉네임을 발급해야 했다 (GitHub #6).

## 결정 (Decision)
닉네임 생성은 자체 라이브러리 `me.suhsaechan:suh-random-engine:1.1.0`의 `SuhRandomKit`(locale `ko`, numberLength 4, uuidLength 4)으로 일원화한다. 중복 회피·재생성 로직만 서비스에 캡슐화한다. 자체 단어 테이블/시드/어드민 CRUD는 두지 않는다 — `nickname_word` 테이블/시드는 마이그레이션 이슈(GitHub #10)에서 제거한다.

## 검토한 대안 (Alternatives)
- 닉네임 단어 풀을 DB(`nickname_word`)로 직접 관리: 이슈 본문은 "시드 데이터 유지보수 부담이 크고, 조합 로직도 별도로 구현해야 한다"고 적었다. 라이브러리가 형용사+명사 약 96만 조합을 제공한다는 점을 근거로 들었다.

## 결과 (Consequences)
**긍정**
- 자체 단어 테이블·시드·어드민 CRUD 불필요 (이슈 본문).

**부정**
- 리포트: 내부망 특성상 라이브러리 빌더 API를 런타임 확인하지 못해 최초 구동 시 검증이 필요하다.
- Suh-Nexus 저장소를 `allowInsecureProtocol`로 등록해야 한다.

## 영향 범위 (Scope)
`server/PQL-Domain-Member/build.gradle`, `server/build.gradle`(저장소), `SuhRandomKitConfig`, `NicknameGenerator`, `MemberService`.

## 출처 (References)
- GitHub #6 이슈 본문 「현재 문제점」·「해결 방안」, `## 개요` 리포트 댓글 (2026-04-07)
- GitHub #10 이슈 본문 (`nickname_word` 불필요)
