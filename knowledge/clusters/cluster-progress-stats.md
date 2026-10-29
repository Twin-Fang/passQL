---
type: cluster
topic: progress-stats
created: 2026-10-29
members: 39
status: active
related: []
---

# 클러스터: progress-stats

## 이 주제는
통계·합격 준비도·학습 현황·순위

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 10개, 열린 이슈 1개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0024-progress-metric-definitions]] — 학습 진도 지표 정의 — 푼 문제는 distinct, 정답률은 문제별 마지막 시도, 스트릭은 하루 그레이스
- [[DEC-0042-ai-comment-cache-evict-on-submit]] — AI 영역 분석 코멘트는 별도 API로 Redis 24시간 캐싱하고, 제출 시 직접 evict한다
- [[DEC-0043-topic-correct-rate-last-7-days]] — 토픽별 정답률은 최근 7일 제출 중 문제별 최근 1회 기준, 토픽별 문제 수는 전체 활성 문제
- [[DEC-0073-session-result-fixed-at-first-submit]] — 세션 결과는 최초 제출 기준으로 고정하고, 복습은 통계에만 반영한다
- [[DEC-0078-readiness-multiplicative-core-with-bonus]] — 합격 준비도 = 3요소 곱셈 코어(Accuracy × Coverage × Recency) × 2요소 보너스 계수
- [[DEC-0174-never-show-total-question-count]] — (사용자 결정) 카테고리 막대는 푼 문제 수의 상대 비율로 보이고, 전체 문제 수는 사용자에게 어디에서도 보여 주지 않는다
- [[DEC-0192-readiness-activity-rings]] — 앱 홈 합격 준비도는 겹친 링 3개(정확도·범위·최신성) + 범례로, 색은 기존 앱 토큰
- [[DEC-0204-profile-drops-info-shown-elsewhere]] — 앱 프로필 탭은 "내 기록을 보는 곳" — 다른 탭에 이미 있는 정보는 빼고 내 상태 > AI 분석 > 영역별 정답률 > 광고 순으로 둔다
- [[DEC-0206-topic-accuracy-list-with-octagon-chart]] — 앱 영역별 정답률은 목록을 기본으로 두고 같은 자리에서 8각 차트로 바꿔 본다 (레이더·막대 두 장 통합, `fl_chart` 제거)

## 대체된 결정 (역사)
- [[DEC-0033-readiness-replaces-progress-rate]] → DEC-0078

## 관련 이슈
- [[ISS-0387-remove-total-question-count-compat]] (open, GitHub #632) — 카테고리별 전체 문제 수(`totalQuestionCount`) 응답 제거 — 구버전 앱 호환 처리와 최소 버전 상향
- [[ISS-0021-progress-api-streak-calculator]] (resolved, GitHub #25) — Progress API 및 StreakCalculator
- [[ISS-0031-daily-study-heatmap-api]] (resolved, GitHub #42) — 날짜별 학습 기록 히트맵 API
- [[ISS-0035-replace-progress-with-readiness]] (resolved, GitHub #52) — 홈 진도율을 합격 준비도(Readiness)로 대체
- [[ISS-0040-home-screen-api-integration]] (resolved, GitHub #67) — 홈 화면 미연동 API 6개 연동 명세
- [[ISS-0044-topic-analysis-ai-comment-api]] (resolved, GitHub #71) — 통계 화면용 토픽별 분석·AI 코멘트 API 부재
- [[ISS-0047-topic-analysis-ai-comment-impl]] (resolved, GitHub #79) — "내 실력, 한눈에" 통계 화면용 토픽별 분석·AI 코멘트 API 구현
- [[ISS-0057-fe-hardcoded-analysis-to-api]] (resolved, GitHub #101) — 프론트 분석 데이터 하드코딩과 UI 개선 필요
- [[ISS-0065-heatmap-tooltip-streak-icon]] (resolved, GitHub #113) — 홈 학습 현황 툴팁 부재와 연속 N일 불꽃 아이콘 강조 부족
- [[ISS-0097-stats-page-ui-overhaul]] (resolved, GitHub #176) — 통계 페이지 UI 전면 개선
- [[ISS-0109-heatmap-not-refreshed-after-submit]] (resolved, GitHub #194) — 문제 풀이 후 홈 학습 현황(heatmap)·streak이 즉시 갱신되지 않음
- [[ISS-0142-heatmap-not-updating-timezone]] (resolved, GitHub #261) — 문제 풀이 후 히트맵 색이 갱신되지 않는 타임존 버그
- [[ISS-0143-readiness-formula-multiplicative-core-bonus]] (resolved, GitHub #262) — 합격 준비도가 1문제만 풀어도 100%가 나오는 산식 결함
- [[ISS-0155-heatmap-stale-after-solving]] (resolved, GitHub #290) — 문제 풀이 후 홈 복귀 시 학습현황 캘린더가 즉시 갱신되지 않음
- [[ISS-0169-radar-chart-untrained-topic-minimum]] (resolved, GitHub #315) — 통계 레이더 차트가 미학습 토픽 때문에 그물 형태를 잃음
- [[ISS-0177-app-daily-set-result-leaderboard]] (resolved, GitHub #332) — 앱 데일리 세트, 결과, 리더보드
- [[ISS-0209-stats-readiness-label-is-correct-rate]] (resolved, GitHub #364) — 통계 "합격 준비도"가 홈 값과 다르고 실제로는 정답률임
- [[ISS-0210-stats-ai-analysis-backticks]] (resolved, GitHub #365) — 통계 AI 영역 분석에 마크다운 백틱이 그대로 노출됨
- [[ISS-0215-qa-observation-candidates]] (resolved, GitHub #370) — QA 관찰 사항 — 이탈 확인·세트 재진입 결과·신규 준비도 등 개선 후보
- [[ISS-0218-readiness-recency-new-user-70]] (resolved, GitHub #373) — 신규 가입 직후 합격 준비도 최신성이 70%로 표시됨
- [[ISS-0220-app-offline-shows-empty-data]] (resolved, GitHub #375) — 서버 연결 실패 시 앱 홈·통계가 오류 대신 빈 데이터로 보임
- [[ISS-0222-withdrawn-member-in-daily-leaderboard]] (resolved, GitHub #377) — 탈퇴한 회원이 오늘의 순위에 `탈퇴회원_xxxx`로 계속 노출됨
- [[ISS-0223-leaderboard-full-list-heading]] (resolved, GitHub #378) — 오늘의 순위 전체 목록에 제목이 없어 내 순위와 중복처럼 보임 (앱)
- [[ISS-0347-heatmap-progress-9-hour-shift]] (resolved, GitHub #560) — 학습 히트맵과 진도 날짜 범위가 9시간 밀림
- [[ISS-0348-daily-set-rescore-after-restart]] (resolved, GitHub #561) — 앱을 다시 켜면 1번부터 다시 풀려 앞에서 본 정답으로 점수를 다시 낼 수 있음
- [[ISS-0352-ai-stats-comment-no-activity-today]] (resolved, GitHub #567) — AI 영역 분석이 오늘 푼 기록을 두고 '10월 21일 이후 활동이 없다'고 서술
- [[ISS-0365-profile-bar-shows-total-questions]] (resolved, GitHub #609) — 내 프로필 카테고리별 막대가 푼 문제가 아닌 전체 문제 수를 보여줌
- [[ISS-0393-active-user-count-analysis]] (resolved, GitHub #645) — 실사용자 수 확인 (관리자 화면·서버 로그) — 분석
- [[ISS-0428-app-profile-tab-redesign]] (resolved, GitHub #749) — 앱 내 프로필 탭 UI/UX 개편 (정보 위계 재구성, passQL PASS 탑승권)
