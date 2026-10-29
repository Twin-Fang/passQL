---
type: decision
id: DEC-0204
created: 2026-10-28
reviewed: null
topics: [progress-stats, home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]"]
---

# DEC-0204: 앱 프로필 탭은 "내 기록을 보는 곳" — 다른 탭에 이미 있는 정보는 빼고 내 상태 > AI 분석 > 영역별 정답률 > 광고 순으로 둔다

## 문제 정의 (Context)
앱 내 프로필 탭이 카드 10장 구조였고, 홈·문제 탭에 있는 정보가 겹쳤다 (GitHub #749 이슈 본문).

## 결정 (Decision)
- 위계(위에서 아래로): 내 상태(이름 줄 > "내 정답률" 큰 숫자 > `N문제 풀었어요 · N일 연속 학습` > 이용권 탑승권) > AI 분석 > 영역별 정답률 > 광고 1칸(지금 규칙 그대로).
- 빼는 것과 원본에 적힌 이유:
  - 합격 준비도, 학습 현황 히트맵: 홈에 있음
  - 오답 노트 행: 문제 탭 토픽 목록에 있음
  - 오늘의 세트 순위 행: 홈 오늘의 세트 「순위 ›」, 세트 결과 화면에 있음
  - 요약 3칸, 닉네임 카드, 지금 등급 카드: 큰 숫자 + 이름 줄 + 탑승권으로 대체
- 탭 이름은 "프로필"(리포트, 2026-10-29 리뷰 반영).

## 검토한 대안 (Alternatives)
논의 기록 없음. (빼는 항목마다 "다른 탭에 이미 있음"이라는 이유만 적혀 있다.)

## 결과 (Consequences)
**긍정**
- 이슈 본문의 기대 결과: 프로필이 "내 기록을 보는 곳"으로 읽히고 홈과 겹치는 정보가 사라진다, 카드 10장에서 구간 4개로 줄어 한 화면에 더 많은 기록이 보인다.
- 리포트: 히트맵·오늘의 세트 묶음(`homeLearningStatusProvider`)을 더 부르지 않아 `/progress` 중복 호출이 없어졌다.

**부정**
- 논의 기록 없음. (리포트: 홈 `ReadinessCard`·`HeatmapWidget`·`SectionOrCard`의 카드형 분기가 쓰이지 않게 됐지만 홈 회귀를 피하려고 남겨 두었다.)

## 영향 범위 (Scope)
앱 `pages/stats/stats_page.dart`, `widgets/profile/*`(신규), `widgets/app_shell.dart`(탭 이름), 삭제된 `summary_stats_section`·`stats_shortcut_section`·`profile_section`·`profile_card` 등. 서버·API 계약·웹은 범위 밖.

## 출처 (References)
- GitHub #749 이슈 본문 「1. 정보 위계」「2. 빼는 것」 (2026-10-28), 리포트 댓글 6490566222 (2026-10-29)
- [[ISS-0428-app-profile-tab-redesign]], [[ISS-0428-app-profile-tab-redesign-report]]
