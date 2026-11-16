---
type: issue
id: ISS-0532
created: 2026-11-16
topics: [progress-stats]
symptoms: ["예상 합격률", "지금 시험 보면 붙을까", "expected-pass", "/api/progress/expected-pass", "ExpectedPassCalculator", "ExpectedPassService", "최근 모의고사 5회", "과락 위험", "합격 준비도"]
root_cause: "합격 준비도(정확도·커버리지·최신성)만 있고 수험생이 바로 이해하는 모의고사 점수 기반 합격 가능성이 없었다(기능 부재)"
status: resolved
resolution: "[[ISS-0531-ox-quiz-expected-pass-lock-screen-ox-report]]"
related: ["[[ISS-0531-ox-quiz-leitner-review]]", "[[ISS-0521-sqld-exam-guide-and-yearly-stats]]"]
source: "_sources/issues/ISS-0532-expected-pass-rate-mock-exam.md"
---

# ISS-0532: 예상 합격률 — 모의고사 점수 기반, 준비도와 통합

GitHub #1086 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1086 · #1083 보고서 공유.

## 증상
합격 준비도는 있지만 "지금 시험 보면 붙을까"를 보여 주지 않았다.

## 재현 조건
앱 프로필·모의고사 목록. 경쟁 서비스 비교(2026-11-14)에서 나온 공백.

## 조사 기록
- 2026-11-14: 이슈 등록(최근 5회 평균, 과목 과락 위험, 모의고사 1회 이상 응시 후 표시, 공식 합격률 비교).
- 2026-11-15: 구현 — 최근 채점 모의고사 최대 5회의 합격 비율·평균·과목 평균, 과락 위험 = 과락선 + 4점 이하, 공식 최근 연도 합격률([[ISS-0521-sqld-exam-guide-and-yearly-stats]] 데이터). 표시는 프로필 카드와 모의고사 목록 한 줄. 준비도 카드와의 통합 방식 대안은 논의 기록 없음. PR #1118 > 릴리스 #1119.

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0531-ox-quiz-expected-pass-lock-screen-ox-report]].
