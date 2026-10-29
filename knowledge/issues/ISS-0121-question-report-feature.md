---
type: issue
id: ISS-0121
created: 2026-04-13
topics: [question-bank, admin]
symptoms: ["문제 신고", QuestionReport, question_report, "POST /api/questions/{questionUuid}/report", "/admin/reports", "소급 보정", CorrectionScope, REPORT_ALREADY_EXISTS]
root_cause: "AI 생성 문제·선택지 오류를 사용자가 신고하고 관리자가 추적할 수단이 없었다"
status: resolved
resolution: "[[ISS-0121-question-report-feature-report]]"
related: ["[[ISS-0125-question-report-api-quality-fixes]]"]
source: "https://github.com/Twin-Fang/passQL/issues/222"
---

# ISS-0121: 문제 신고 기능 (신고 API, 관리자 관리 화면)

GitHub #222 (원본: 이슈 본문과 댓글).

## 증상
AI가 생성한 선택지·문제에 오류가 있어도 사용자가 신고할 수단이 없고, 오류 문제로 정답률이 억울하게 떨어질 수 있으며, 관리자가 품질 이슈를 추적할 방법이 없다(이슈 본문).

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-13: 이슈 등록. 계획: 결과 바텀시트 신고 버튼(결과 확인 후에만), 복수 선택 카테고리(정답 오류 / 문제 오류 / 선택지 오류 / SQL 실행 결과 오류 / 기타), 관리자 문제별 집계 → 상세, 처리 시 문제 비활성화와 Submission 소급 보정(범위: 문제 전체 or 선택지 세트).
- 백엔드 계획: `QuestionReport` 엔티티, `ReportCategory`·`ReportStatus`·`CorrectionScope` Enum, `question_report`·`question_report_category` 테이블, `POST /api/questions/{questionUuid}/report`, `GET /api/questions/{questionUuid}/report/status`, `GET /admin/api/reports`, `GET /admin/api/reports/{questionUuid}`, `POST /admin/api/reports/{reportUuid}/resolve`, `QuestionReportService`, ErrorCode `REPORT_ALREADY_EXISTS`·`REPORT_NOT_FOUND`·`REPORT_ALREADY_RESOLVED`.
- 2026-04-13: 서버 빌드 후 관리자 신고 화면 스크린샷, "프론트측 API 연결이 필요합니다". 같은 날 후속 품질 수정 GitHub #227.

## 근본 원인
기능 부재.
