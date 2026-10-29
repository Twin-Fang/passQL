---
type: issue
id: ISS-0125
created: 2026-04-13
topics: [question-bank, admin]
symptoms: ["N+1", "GET /admin/api/reports", "Controller 검증 로직", Timestamp, ClassCastException, question_report_category, "복합 PK 누락", DuplicateMappingException, JoinColumn]
root_cause: "문제 신고 API(GitHub #222) 구현에 N+1 조회, Controller 검증, 불안전한 Timestamp 캐스팅, 복합 PK 누락이 남았다"
status: resolved
resolution: "[[ISS-0125-question-report-api-quality-fixes-report]]"
related: ["[[ISS-0121-question-report-feature]]"]
source: "https://github.com/Twin-Fang/passQL/issues/227"
---

# ISS-0125: 문제 신고 API 코드 품질 버그

GitHub #227 (원본: 이슈 본문, 댓글, 리포트 댓글).

## 증상
- `GET /admin/api/reports`에서 신고 건수만큼 문제 stem을 개별 조회(N+1).
- 신고 입력 검증이 Controller에 있음(CLAUDE.md "Controller에 비즈니스 로직 금지" 위반).
- nativeQuery 결과 `Timestamp` 캐스팅이 드라이버에 따라 `ClassCastException` 가능.
- `question_report_category`에 복합 PK가 없어 같은 카테고리 중복 삽입 가능.

## 재현 조건
1. `GET /admin/api/reports` 호출 시 N+1 쿼리 2. `POST /api/questions/{questionUuid}/report`의 검증이 Controller에서 수행 3. 같은 `(question_report_uuid, category)` 중복 삽입이 DB에서 막히지 않음.

## 조사 기록
- 2026-04-13: 이슈 등록. 관련 `QuestionReportService.java`, `AdminReportController.java`, `QuestionReportController.java`, `V0_0_120__add_question_report.sql`. 댓글: GitHub #222 브랜치에서 작업.
- 2026-04-13: 수정 중 `QuestionReport` 엔티티의 `@JoinColumn(name = ...)`으로 `DuplicateMappingException`이 나 서버가 기동되지 않는 문제도 발견(리포트).

## 근본 원인
신고 API 초기 구현의 품질 결함(위 4가지)과 `@JoinColumn(name)` 명시로 인한 매핑 중복.
