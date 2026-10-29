---
type: issue
id: ISS-0209
created: 2026-10-07
topics: [progress-stats]
symptoms: [합격 준비도 값 불일치, 통계 38% 홈 31%, progress.correctRate, readiness.score, summary_stats_section.dart]
root_cause: "`summary_stats_section.dart`가 `progress.correctRate`(정답률)를 \"합격 준비도\" 라벨로 표시했다"
status: resolved
resolution: "[[ISS-0209-stats-readiness-label-is-correct-rate-report]]"
related: ["[[ISS-0215-qa-observation-candidates]]"]
source: "https://github.com/Twin-Fang/passQL/issues/364"
---

# ISS-0209: 통계 "합격 준비도"가 홈 값과 다르고 실제로는 정답률임

GitHub #364 (원본: 이슈 본문과 댓글).

## 증상
홈: 합격 준비도 31%, 정확도 38%. 통계 탭 상단 카드: "합격 준비도" 38%. 통계 카드는 실제로 정답률을 "합격 준비도"라는 이름으로 보여 준다.

## 재현 조건
QA GitHub #357 영역 7(iPhone 16 Pro, 실계정): 홈과 통계 탭의 합격 준비도 값 비교.

## 조사 기록
- 2026-10-07: 홈은 `readiness.score`(정확도×범위×최신성), 통계는 `progress.correctRate`를 씀.

## 근본 원인
라벨 오표기.
