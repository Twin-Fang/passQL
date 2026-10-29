---
type: issue
id: ISS-0130
created: 2026-04-13
topics: [practice]
symptoms: ["채점 중이에요", LoadingOverlay, PracticeFeedbackBar, EXECUTABLE, CONCEPT_ONLY, "실제 DB 실행 미노출", 마이크로카피]
root_cause: "채점 화면 문구가 EXECUTABLE·CONCEPT_ONLY 구분 없이 동일해 실제 Oracle DB 실행 채점 사실이 노출되지 않음"
status: resolved
resolution: "[[ISS-0130-executable-grading-db-microcopy-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/236"
---

# ISS-0130: EXECUTABLE 문제 채점 시 실제 DB 실행 사실이 드러나지 않음

GitHub #236 (원본: 이슈 본문과 댓글).

## 증상
채점 로딩 화면과 피드백 바에 "채점 중이에요" / "정답이에요!"만 표시된다. 원본은 실제 Oracle DB에서 SQL을 실행해 정답을 판정하는 것을 "핵심 기술 차별점"이라 부르며, 이것이 사용자에게 노출되지 않고 EXECUTABLE과 CONCEPT_ONLY 문제가 같은 UX라고 적었다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-13: 제안 — EXECUTABLE 채점 중 `LoadingOverlay`와 채점 후 `PracticeFeedbackBar` 해설 아래에 5개 중 랜덤 문구, CONCEPT_ONLY에는 미표시.

## 근본 원인
해당 없음 (문구 미구현).
