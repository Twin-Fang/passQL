---
type: issue
id: ISS-0529
created: 2026-11-16
topics: [practice, progress-stats]
symptoms: ["오답률 TOP 30", "가장 많이 틀리는 문제", "전체 사용자 오답률", "hardest", "/api/questions/hardest", "HardestQuestionRanker", "HardestQuestionService", "첫 제출 집계", "최소 응시 수 20명", "1시간 캐시", "HardestFlow"]
root_cause: "전체 사용자 기준으로 많이 틀리는 문제를 모아 볼 화면이 없었다(개념 TOP 10 은 출제 빈도 순위, 기능 부재)"
status: resolved
resolution: "[[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]]"
related: ["[[ISS-0528-wrong-note-subject-filter-retry-set]]", "[[ISS-0530-question-bookmark-practice]]"]
source: "_sources/issues/ISS-0529-hardest-questions-top30.md"
---

# ISS-0529: 전체 사용자 기준 오답률 TOP 30

GitHub #1080 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1080 · 복습 묶음 보고서 공유.

## 증상
- "가장 많이 틀리는 문제"를 모아 볼 수 없었다. 앱의 "개념 TOP 10"은 출제 빈도 순위다.
- 제출 기록은 쌓이고 있어 집계만 하면 되는 상태였다.

## 재현 조건
앱 문제 탭. 경쟁 서비스 비교(2026-11-14)에서 나온 복습 기능 공백.

## 조사 기록
- 2026-11-14: 이슈 등록(최소 응시 수 이하 제외, 가장 많이 고른 오답 보기, 개정 범위 밖 문항 표시, 미리 계산 제안).
- 2026-11-15: 복습 묶음으로 구현. 회원별 첫 제출만 집계·테스트 계정 제외·첫 제출 20명 이상만·1시간 캐시. PR #1108 > 릴리스 #1112 배포.
- 가장 많이 고른 오답 보기·개정 범위 표시는 보고서에 없다.

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]].
