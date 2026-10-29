---
type: issue
id: ISS-0339
created: 2026-10-20
topics: [practice]
symptoms: ["피드백 바", "하단 바 가림", "정답 보기 안 보임", ensureVisible, keepVisibleAtEnd, extendBody, question_solving_body.dart, chapter_page.dart, "실행 결과 자동 스크롤"]
root_cause: "extendBody 풀이 화면에서 제출 후 하단 바가 커져도 스크롤 보정이 없고, ensureVisible이 하단 바 높이를 모른 채 뷰포트 끝에 맞췄다"
status: resolved
resolution: "[[ISS-0339-feedback-bar-covers-choices-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/551"
---

# ISS-0339: 제출 후 하단 피드백 바가 보기와 실행 결과를 가림

GitHub #551 (원본: 이슈 본문과 댓글).

## 증상
- 제출하면 하단 바가 제출 버튼(약 100pt)에서 피드백 바(약 310pt, 화면의 약 35%)로 커지는데 스크롤 위치는 그대로라 보던 보기를 덮는다. 7번 문제에서는 정답 A가 아예 안 보이고 고른 B도 일부만 보인다.
- 채점 후 다른 SQL 보기를 누르면 실행 결과 카드로 자동 스크롤하지만 피드백 바 뒤에서 멈춘다(`question_solving_body.dart:190` ensureVisible keepVisibleAtEnd, 하단 바 높이 미반영).
- 피드백 바 높이가 해설 길이에 따라 약 265 ~ 310pt로 문제마다 다르다.

## 재현 조건
앱 홈 > 오늘의 세트(2026-10-20) > 7번, 보기 B가 화면 아래쪽에 오도록 스크롤 후 선택 > 제출. 3번 채점 후 보기 C 탭 > 실행 결과 카드가 피드백 바 뒤에서 멈춤. iOS 18.3 시뮬레이터, main 0e2fda60.

## 조사 기록
- 2026-10-20: 관련 위치 `app/lib/presentation/pages/questions/chapter_page.dart`(extendBody + bottomNavigationBar 교체), `question_solving_body.dart:190`.

## 근본 원인
풀이 화면은 `extendBody`라 본문이 하단 바 아래까지 깔리는데, `ensureVisible`은 뷰포트 끝 기준이라 바 뒤에서 멈췄다. 제출 직후 바가 커질 때 스크롤 보정이 없었다.
