---
type: decision
id: DEC-0023
created: 2026-04-08
reviewed: null
topics: [ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0018-submission-table-question-active]]", "[[ISS-0018-submission-table-question-active-report]]", "[[ISS-0026-frontend-sync-api-v003]]"]
---

# DEC-0023: 모든 엔티티 PK를 UUID로 (전체 스키마 전면 전환)

## 문제 정의 (Context)
GitHub #22에서 `submission` 테이블과 `question.is_active`를 추가하면서 PK 규칙을 정했다.

## 결정 (Decision)
모든 PK는 UUID(`@GeneratedValue(UUID)`)로 하고, 컬럼명은 camelCase Java 필드 → snake_case 자동 변환을 따른다 (이슈 본문). 완료 댓글: "전체 스키마에 대해서 전면 수정 UUID로 id변경했습니다".

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- GitHub #35: 모든 Entity ID가 Long → UUID로 바뀌어 API 스펙이 대폭 변경됐고, 프론트 타입·API·라우트(`/questions/:id` → `/questions/:questionUuid`)를 일괄 수정해야 했다.

## 영향 범위 (Scope)
전체 JPA 엔티티와 Flyway 스키마, 공개 API 경로·DTO, 프론트 타입·라우팅.

## 출처 (References)
- GitHub #22 이슈 본문 「해결 방안」, 완료 댓글 (2026-04-08)
- GitHub #35 이슈 본문
