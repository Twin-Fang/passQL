---
type: completion-report
id: ISS-0125
created: 2026-04-13
topics: [question-bank, admin]
status: resolved
resolves: "[[ISS-0125-question-report-api-quality-fixes]]"
related: ["[[ISS-0121-question-report-feature-report]]", "[[DEC-0072-idempotent-ddl-migrations]]"]
source: "https://github.com/Twin-Fang/passQL/issues/227"
---

# ISS-0125 완료 리포트: 배치 조회, Service 검증, Timestamp 다형 처리, 복합 PK, `@ManyToOne` 제거

GitHub #227 `## 개요` 리포트 댓글 기준 (2026-04-13).

## 해결 방법
- `QuestionReportService`: `getReportSummaries()`의 반복 `findById`를 `questionRepository.findAllById(questionUuids)` 1회 + `Map<UUID, String>`으로. 검증(`submissionUuid` null, `categories` 비어있음, `ETC`면 `detail` 필수, 중복 신고)을 Controller에서 Service로 이동. nativeQuery `row[3]`을 `instanceof Timestamp` / `instanceof LocalDateTime`으로 분기. `resolveReport()`에 `correctionScope == null` 방어, `RESOLVED` 재처리 차단, `CHOICE_SET_ONLY` 시 `choiceSetUuid` 존재 검증. `ReportSummaryRow` record 도입.
- `QuestionReportController`: 검증 제거, 요청/응답 변환만.
- `QuestionReport` 엔티티: `@ManyToOne` + `@JoinColumn(name = "question_uuid")`, `@JoinColumn(name = "choice_set_uuid")` 제거, UUID 필드만 유지(연관 객체를 쓰는 코드가 없어서).
- `V0_0_126__add_pk_to_question_report_category.sql`: 복합 PK `(question_report_uuid, category)`, `DO $$` 블록 + `IF NOT EXISTS`로 멱등([[DEC-0072-idempotent-ddl-migrations]]).

## 근본 원인 (확정)
위 4가지 결함과, `@JoinColumn(name = "...")` 명시 시 Hibernate가 같은 물리 컬럼(`choice_set_uuid`)을 논리 이름(`choiceSetUuid`)과 중복 매핑으로 인식한 `DuplicateMappingException`. 리포트: CLAUDE.md의 `@Column(name = ...)` 금지 규칙과 같은 맥락(PhysicalNamingStrategy 충돌).

## 재발 방지
리포트 주의사항: 연관 객체가 필요해지면 `@JoinColumn`에 `name` 없이 `referencedColumnName`만으로 재도입 검토. 복합 PK는 `V0_0_126` 성공 이후부터 적용 — 이전 중복 데이터는 직접 확인 필요.

## 교훈
(원본에 없음, 볼트 정리) 서버가 `DuplicateMappingException`으로 기동되지 않으면 `@Column`/`@JoinColumn`의 `name` 명시부터 찾는다.
