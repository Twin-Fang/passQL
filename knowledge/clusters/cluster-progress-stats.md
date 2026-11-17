---
type: cluster
topic: progress-stats
created: 2026-10-29
members: 64
status: active
related: []
---

# 클러스터: progress-stats

## 이 주제는
통계·합격 준비도·학습 현황·순위

## 현재 상태 요약
(2026-11-07, 자동 생성) 활성 결정 12개, 열린 이슈 1개. 영역별 정답률은 레이더 그래프 위, 목록 아래(토글 없음)이고 학습 패턴(최근 4주 학습, 공부하는 시간)은 무료, 정답률 상세(난이도별, 오답 정리)는 프로, 판정은 서버 계산기: [[DEC-0274-stats-radar-above-list-study-pattern-free]] (#909, DEC-0206 대체, main 머지, 배포 전). 통계 AI 분석은 서버 판정 + LLM 한 문장 — [[DEC-0259-ai-analysis-server-decides-llm-explains]], 과목별 예상 점수·과락 판정 — [[DEC-0260-exam-forecast-score-thresholds]] (#862, 릴리스 #888). 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다. (2026-11-13) 모의고사 결과 순위(상위 N%)는 [[DEC-0301-mock-exam-ranking-first-attempt-top-percent]]. (2026-11-16) SQLD 시험 소개·연도별 응시자·합격률 통계는 서버 JSON 단일 원본 공개 API — [[DEC-0318-exam-guide-single-source-public-api]], 회차별 합격률은 확인된 전언만 비공식 표시 — [[DEC-0319-round-pass-rate-unofficial-only]] (#1077, 서버·소개 사이트 배포, 앱 대기). (2026-11-16) 예상 점수 설명을 과락·합격선 여유 문항 수로 — [[DEC-0323-pass-fail-margin-count-single-source]], 점수 올리기 좋은 영역 +N점 — [[DEC-0322-score-gain-topics-exam-weighted]] (#1111, 릴리스 #1115). (2026-11-16) 가답안 공유 이미지는 다크 모드여도 흰 바탕 — [[DEC-0332-exam-answer-share-image-always-light]](DEC-0321 대체); 모의고사 순위는 빈 답안 제외 — [[DEC-0333-mock-exam-ranking-excludes-empty-attempts]] (#1126, 릴리스 #1130). (2026-11-16) AI 분석 한 줄 요약의 과락 판정은 예상 점수와 같은 원본 — [[DEC-0334-ai-analysis-fail-risk-single-source]], 분석 캐시 키에 형식 버전 v3 — [[DEC-0335-stats-analysis-cache-key-schema-version]] (#1136, 릴리스 #1138).

## 활성 결정
- [[DEC-0343-app-difficulty-three-segment-band-with-label]] — 난이도는 가로 3칸 띠 + 글자(쉬움 1칸, 보통 2칸, 어려움 3칸) 공통 부품 `PassqlDifficultyIndicator`, 풀이 머리·홈 추천·프로필 적용, 홈 추천 칩은 제목 위 회색 메타 한 줄 + DEC-0342의 3단계 구간·프로필 3행 유지 (#1147)
- [[DEC-0301-mock-exam-ranking-first-attempt-top-percent]] — 모의고사 결과에 같은 회차 "상위 N%" 한 줄, 회원별 첫 응시 기준·응시자 10명 미만 숨김·무료 공개 (#1041)
- [[DEC-0333-mock-exam-ranking-excludes-empty-attempts]] — 모의고사 순위에서 빈 답안(한 문항도 안 고른 제출)은 응시자로 세지 않고, 내 응시가 빈 답안이면 순위 숨김 (#1126, DEC-0301 보완)
- [[DEC-0024-progress-metric-definitions]] — 학습 진도 지표 정의 — 푼 문제는 distinct, 정답률은 문제별 마지막 시도, 스트릭은 하루 그레이스
- [[DEC-0042-ai-comment-cache-evict-on-submit]] — AI 영역 분석 코멘트는 별도 API로 Redis 24시간 캐싱하고, 제출 시 직접 evict한다
- [[DEC-0043-topic-correct-rate-last-7-days]] — 토픽별 정답률은 최근 7일 제출 중 문제별 최근 1회 기준, 토픽별 문제 수는 전체 활성 문제
- [[DEC-0073-session-result-fixed-at-first-submit]] — 세션 결과는 최초 제출 기준으로 고정하고, 복습은 통계에만 반영한다
- [[DEC-0078-readiness-multiplicative-core-with-bonus]] — 합격 준비도 = 3요소 곱셈 코어(Accuracy × Coverage × Recency) × 2요소 보너스 계수
- [[DEC-0174-never-show-total-question-count]] — (사용자 결정) 카테고리 막대는 푼 문제 수의 상대 비율로 보이고, 전체 문제 수는 사용자에게 어디에서도 보여 주지 않는다
- [[DEC-0192-readiness-activity-rings]] — 앱 홈 합격 준비도는 겹친 링 3개(정확도·범위·최신성) + 범례로, 색은 기존 앱 토큰
- [[DEC-0204-profile-drops-info-shown-elsewhere]] — 앱 프로필 탭은 "내 기록을 보는 곳" — 다른 탭에 이미 있는 정보는 빼고 내 상태 > AI 분석 > 영역별 정답률 > 광고 순으로 둔다
- [[DEC-0258-ai-comment-pro-only-all-forms]] — AI 코멘트는 결과·통계 모두 프로 전용 (#699 무료 하루 1회 폐지, #860)
- [[DEC-0259-ai-analysis-server-decides-llm-explains]] — 통계 AI 분석: 서버가 판정·우선순위·문구, LLM 은 토픽별 헷갈리는 개념 한 문장 (#861)
- [[DEC-0260-exam-forecast-score-thresholds]] — 과목별 예상 점수는 서버 계산(1과목 data_modeling×10, 2과목 8토픽 평균×40, ×2점), 과목 40% 미만 과락·70점 합격권·54~68 합격선 근처 (#862)
- [[DEC-0274-stats-radar-above-list-study-pattern-free]]: 영역별 정답률은 레이더 그래프 위, 목록 아래(토글 없음), 학습 패턴 무료, 정답률 상세(난이도, 오답 정리) 프로 (#909, DEC-0206 대체)
- [[DEC-0318-exam-guide-single-source-public-api]]: SQLD 시험 소개·역대 통계는 서버 JSON 단일 원본 + 공개 API(GET /api/meta/exam-guide/sqld)를 앱·소개 사이트가 함께 읽음
- [[DEC-0319-round-pass-rate-unofficial-only]]: 합격률은 연도별 공식 값만 수치로, 회차별은 확인된 전언(61회 약 26%)만 비공식 배지로
- [[DEC-0322-score-gain-topics-exam-weighted]] — 점수 올리기 좋은 영역 = 출제 문항 수 × (75% − 정답률) × 2점, 5문제 이상·0.5점 이상 상위 3개, 통계 AI 분석 안(프로) (#1111)
- [[DEC-0323-pass-fail-margin-count-single-source]] — 과락·합격선 여유는 문항 수로, 서버 SqldScoreMargin(MockExamRule 기준) 한 곳, 합격선 문장 무료·과목 여유 프로 (#1111)
- [[DEC-0334-ai-analysis-fail-risk-single-source]] — AI 분석 한 줄 요약의 과락 판정은 예상 점수와 같은 원본(ExamForecastCalculator.failRiskSubjectsOf > SqldScoreMargin), "2과목 예상 14/40, 과락 위험이 커요" (#1136)
- [[DEC-0335-stats-analysis-cache-key-schema-version]] — 통계 AI 분석 캐시 키에 형식 버전(현재 v3), 응답 필드·판정 규칙이 바뀌면 버전을 올림 (#1136, DEC-0042 보완)

## 대체된 결정 (역사)
- [[DEC-0342-app-difficulty-text-label-three-levels]] → [[DEC-0343-app-difficulty-three-segment-band-with-label]] — 난이도 회색 글자 > 가로 3칸 띠 + 글자 (#1147)
- [[DEC-0033-readiness-replaces-progress-rate]] → DEC-0078
- [[DEC-0206-topic-accuracy-list-with-octagon-chart]] → DEC-0274

## 관련 이슈
- [[ISS-0541-app-difficulty-three-segment-band]] (resolved, #1147, PR #1148, 앱 배포 전): 난이도 가로 3칸 띠 공통 부품 `PassqlDifficultyIndicator`, 홈 추천 칩 > 회색 메타 한 줄. 완료 리포트 [[ISS-0541-app-difficulty-three-segment-band-report]]
- [[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking]] (resolved, #1126) — SQLD 63회 가답안·모의고사 결과 실기 검수 결함 7건: 빈 답안 순위 제외, 공유 이미지 흰 바탕, 합의율 응답 5명 미만이면 "응답 N명", 관리자 답안지 삭제. 완료 리포트 [[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking-report]] (PR #1127, 릴리스 #1130)
- [[ISS-0532-expected-pass-rate-mock-exam]] (resolved, #1086): 예상 합격률(최근 채점 모의고사 최대 5회, 과락 위험 = 과락선 + 4점 이하). 완료 리포트 [[ISS-0531-ox-quiz-expected-pass-lock-screen-ox-report]]
- [[ISS-0529-hardest-questions-top30]] (resolved, #1080): 전체 사용자 오답률 TOP 30(회원별 첫 제출, 20명 이상, 1시간 캐시). 완료 리포트 [[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]]
- [[ISS-0528-wrong-note-subject-filter-retry-set]] (resolved, #1081): 오답노트 과목 필터·많이 틀린 순·정리된 오답 숨기기·오답 10문제 다시 풀기, 복습 묶음 PR #1108·릴리스 #1112. 완료 리포트(#1080·#1082 공유) [[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]]
- [[ISS-0511-qa-1112-ui-polish-eight]] (resolved, #1041, PR #1042): 11/12 QA UI 개선 8건 — 환영 시트·알림 안내·모의고사 순위·크레딧 아이콘·PK FK·난이도 별·카운트업·과락 칸
- [[ISS-0477-stats-radar-default-study-pattern]] (resolved, GitHub #909): 통계 화면 개편: 육각형 그래프 기본, 차트와 학습 통계 추가
- [[ISS-0460-ai-analysis-forecast-concept-links]] (resolved, GitHub #862) — 통계 AI 분석 보강: 과목별 예상 점수, 개념 바로 가기, 빈 데이터 안내, 세션 코멘트 개편
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
- [[ISS-0521-sqld-exam-guide-and-yearly-stats]] (resolved, #1077·#1076): SQLD 알아보기(시험 소개, 연도별 응시자·합격률) — 서버 API·소개 사이트 sqld/stats/, 앱 PR #1102·릴리스 #1104 출시(iOS 1.132.0 재제출). 완료 리포트 [[ISS-0521-sqld-exam-guide-and-yearly-stats-report]]
- [[ISS-0525-pass-fail-margin-score-gain-topics]] (resolved, #1111) — 과락·합격선 여유 문항 수 안내, 점수 올리기 좋은 영역 +N점
- [[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner]] (resolved, #1136) — 프로 계정 재검수 결함 5건: AI 분석 과락 판정 불일치, 가채점 계정 분리, 점수 올리기 영역 캐시, 응답 0명·AI 분석·풀이 머리 정리. 완료 리포트 [[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner-report]]
