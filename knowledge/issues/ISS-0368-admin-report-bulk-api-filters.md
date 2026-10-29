---
type: issue
id: ISS-0368
created: 2026-10-24
topics: ["admin", "question-bank"]
symptoms: ["신고 일괄 처리", "resolve 순차 호출", "부분 실패", "report-detail.js", "AdminReportController", "사유별 집계 빈 맵"]
root_cause: "일괄 처리가 클라이언트 JS의 신고별 순차 resolve 호출이었고, 사유 집계가 빈 맵으로 하드코딩돼 있었다"
status: resolved
resolution: null
related: ["[[ISS-0366-admin-question-quality-metrics-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/613"
---

# ISS-0368: 신고 처리 서버 일괄 API가 없고 사유 집계가 하드코딩·필터 없음

GitHub #613 (원본: 이슈 본문; 완료 내용은 GitHub #611 통합 리포트 댓글).

## 증상
신고 전체 처리가 JS에서 신고마다 resolve를 순차 호출해 부분 실패 시 일관성이 깨진다(`report-detail.js:176-189`). 사유별 집계가 빈 맵으로 하드코딩돼 있다(`AdminReportController.java:44`). 정렬·상태·기간 필터와 처리 메모가 없다.

## 재현 조건
여러 신고를 한 번에 처리하다 중간 호출이 실패하는 경우(원본 기준). 구체 재현 기록은 원본에 없다.

## 조사 기록
- 2026-10-24: 관리자 화면만으로 운영(DB 직접 조회 없이)하기 위한 관리자 개선 묶음(GitHub #611~#631) 중 하나로 등록. 공통 조건: 관리자 변경 작업은 기존 `AdminAuditLogService`로 감사 로그, 서버 API 변경 시 `api-contract/openapi.json` 갱신까지 한 커밋.
- 작업 범위: 서버 단위 일괄 처리 API(한 트랜잭션), 사유(category)별 집계 채우기, 신고 많은 순 정렬·처리됨·기각 필터·기간 필터, 처리 사유 메모와 개별 선택 후 처리.
- 2026-10-24: GitHub #611 통합 구현 보고서(PR #634, 운영 배포) 결과 — 신고 서버 일괄 처리 API, 사유 집계, 필터·정렬, 처리 메모 완료. 이 이슈 자체에는 완료 댓글이 없어 완료 리포트는 #611 쪽에 있다.

## 근본 원인
원본 「현재 문제점」 기준: 일괄 처리가 서버가 아니라 JS에서 신고마다 resolve를 순차 호출하는 구조(`report-detail.js:176-189`)라 부분 실패 시 일관성이 깨지고, 사유별 집계는 빈 맵 하드코딩(`AdminReportController.java:44`)이었다.
