---
type: issue
id: ISS-0057
created: 2026-04-11
topics: [practice, progress-stats, home]
symptoms: ["하드코딩 분석 데이터", "목 데이터", PracticeResult, fetchAiComment, "디자인 가이드 불일치", "버전 하드코딩"]
root_cause: "분석·통계 데이터가 실제 API가 아닌 하드코딩·목 데이터로 표시됐다"
status: resolved
resolution: "[[ISS-0057-fe-hardcoded-analysis-to-api-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/101"
---

# ISS-0057: 프론트 분석 데이터 하드코딩과 UI 개선 필요

GitHub #101 (원본: 이슈 본문과 댓글).

## 증상
학습 통계·진행 현황 등 분석 결과가 실제 API가 아닌 하드코딩·목 데이터로 표시되어 실제 사용자 데이터가 반영되지 않는다. 일부 화면 UI가 디자인 가이드와 맞지 않는다.

## 재현 조건
해당 없음 (개선 이슈).

## 조사 기록
- 2026-04-11: 프론트 작업 댓글.

## 근본 원인
화면이 실 API 연동 전 상태로 남아 있었다.
