---
type: issue
id: ISS-0530
created: 2026-11-16
topics: [practice]
symptoms: ["즐겨찾기", "북마크", "찜", "question_bookmark", "/api/bookmarks", "practice-set", "isBookmarked", "별 버튼", "BookmarkFlow", "즐겨찾기 랜덤 10문제"]
root_cause: "다시 보고 싶은 문제를 저장할 방법(북마크·찜 API)이 없었다(기능 부재)"
status: resolved
resolution: "[[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]]"
related: ["[[ISS-0528-wrong-note-subject-filter-retry-set]]", "[[ISS-0529-hardest-questions-top30]]"]
source: "_sources/issues/ISS-0530-question-bookmark-practice.md"
---

# ISS-0530: 문제 즐겨찾기와 즐겨찾기 문제 풀기

GitHub #1082 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1082 · 복습 묶음 보고서 공유.

## 증상
다시 보고 싶은 문제를 저장할 방법이 없었다(북마크·찜 API 없음).

## 재현 조건
문제 풀이·해설·오답노트·모의고사 결과 화면. 경쟁 서비스 비교(2026-11-14)에서 나온 복습 기능 공백.

## 조사 기록
- 2026-11-14: 이슈 등록. 무료 개수 상한·프로 무제한 여부는 설계에서 정하기로 함.
- 2026-11-15: 복습 묶음으로 구현. 무료 포함 개수 제한 없음으로 정함(보고서, 다른 대안 논의 기록 없음). 해설 결과 화면(`ResultPage`)에는 별 없음. PR #1108 > 릴리스 #1112 배포.

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]].
