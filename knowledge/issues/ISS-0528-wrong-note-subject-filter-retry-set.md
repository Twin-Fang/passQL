---
type: issue
id: ISS-0528
created: 2026-11-16
topics: [practice, progress-stats]
symptoms: ["오답노트", "오답노트 필터 없음", "많이 틀린 순", "과목별 보기", "오답 다시 풀기", "10문제 다시 풀기", "정리된 오답", "getWrongQuestions", "wrong-questions", "retry-set", "WrongNoteSelector", "WrongNoteRetryFlow", "isResolved", "wrongCount"]
root_cause: "오답노트가 최근 틀린 순 20개 목록뿐이라 과목·정렬 필터와 오답을 묶어 다시 푸는 흐름이 없었다(기능 부재)"
status: resolved
resolution: "[[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]]"
related: ["[[ISS-0529-hardest-questions-top30]]", "[[ISS-0530-question-bookmark-practice]]", "[[ISS-0521-sqld-exam-guide-and-yearly-stats]]"]
source: "_sources/issues/ISS-0528-wrong-note-subject-filter-retry-set.md"
---

# ISS-0528: 오답노트 — 과목별 보기, 많이 틀린 순, 10문제 다시 풀기

GitHub #1081 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1081 · 복습 묶음(#1081·#1080·#1082) 보고서 1개를 공유.

## 증상
- 오답노트는 최근 틀린 순 20개 목록만 있고 필터·정렬이 없었다(`ProgressService.getWrongQuestions`, API 인자 `size` 하나).
- 틀린 문제를 묶어 다시 푸는 흐름이 없어 하나씩 들어가야 했다.

## 재현 조건
앱 문제 탭 > 오답노트. 경쟁 서비스 비교(2026-11-14)에서 나온 복습 기능 공백.

## 조사 기록
- 2026-11-14: 이슈 등록. 출처별(문제 풀이·모의고사·기출 회차) 보기 제안.
- 2026-11-15: 복습 묶음 한 브랜치(`20261116_#1081_복습_묶음_오답노트_즐겨찾기_오답률_TOP`)로 구현, 앱 브랜치 빌드. PR #1108 > 릴리스 PR #1112 배포.
- 출처별 보기는 보고서에 없다 — 구현은 과목 필터·정렬·정리됨 숨기기·다시 풀기 세트.

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]].
