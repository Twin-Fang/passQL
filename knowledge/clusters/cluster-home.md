---
type: cluster
topic: home
created: 2026-10-29
members: 65
status: active
related: []
---

# 클러스터: home

## 이 주제는
홈 화면·추천

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 21개, 열린 이슈 0개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0033-readiness-replaces-progress-rate]] — 홈 지표를 진도율 대신 합격 준비도 `Readiness = Accuracy × Coverage × Recency`로
- [[DEC-0034-greeting-nickname-template-message-type]] — 인사말 응답은 `nickname`·`{nickname}` 템플릿·`messageType`으로 나누고, 이모지·아이콘은 프론트가 정한다
- [[DEC-0035-greeting-dday-weighted-mix]] — D-day 구간에도 일반 인사말을 섞고, 시험이 가까울수록 D-day 메시지 비중을 높인다
- [[DEC-0039-home-sections-independent-failure]] — 홈 섹션은 API별로 독립 호출하고, `progress` 실패만 전체 에러 화면, 나머지는 조용히 숨긴다
- [[DEC-0048-daily-challenge-wrong-answer-not-submitted]] — 데일리 챌린지는 정답일 때만 서버에 제출하고, 오답은 로컬 피드백 후 다시 풀게 한다
- [[DEC-0059-ai-question-terminology]] — 사용자 화면의 "문제"를 "AI문제"로 통일하고 lucide `Sparkles`를 AI 표시 전용 아이콘으로 쓴다
- [[DEC-0062-separate-recommendation-practice-page]] — 홈 추천 문제는 QuestionDetail 직접 링크 대신 전용 `RecommendationPractice` 페이지로 풀고, 정답·오답 모두 제출 기록한다
- [[DEC-0077-rag-recommendation-with-random-fallback]] — 문제 추천은 Qdrant 벡터 검색 기반 개인화, 신호 집계는 Java·검색은 Python, 실패 시 RANDOM 폴백
- [[DEC-0083-session-scoped-recommendation-exclusion]] — 추천 새로고침은 이번 세션에서 본 문제만 제외하고, 푼 문제 영구 제외는 하지 않는다
- [[DEC-0084-recommendation-exclusion-post-body-fifo]] — 추천 제외 목록은 GET 쿼리가 아니라 POST 본문으로 보내고, 클라이언트는 최신 30개만 유지한다
- [[DEC-0090-app-no-separate-recommendation-screen]] — 앱은 추천 문제 전용 풀이 화면을 만들지 않고 일반 문제 풀이 화면을 그대로 쓴다
- [[DEC-0166-tab-roles-home-read-questions-solve]] — 탭마다 역할 하나 — 홈은 읽을 것, 문제 탭은 풀 것 전부, 설정은 설정만 (출제 경향 전용 화면 폐지)
- [[DEC-0167-five-tabs-with-text-labels]] — 하단 탭 5개는 유지하고 아이콘 아래에 이름(홈 / 문제 / 토론 / 기록 / MY)을 표시한다
- [[DEC-0171-four-tabs-merge-stats-my-profile]] — 하단 탭을 홈 / 문제 / 토론 / 내 프로필 4개로 — 기록과 MY를 `내 프로필`로 합치고 설정은 톱니바퀴로 여는 push 화면
- [[DEC-0179-remove-countdown-keep-exam-day-urgent]] — 홈 인사 배지에서 `COUNTDOWN`만 없애고 `EXAM_DAY`·`URGENT`는 유지, 서버 `messageType`은 그대로 둔다
- [[DEC-0182-home-not-wait-recommendations]] — 앱 홈 첫 표시는 추천 문제를 기다리지 않는다 (추천은 도착 후 맨 아래에 붙임)
- [[DEC-0189-home-section-layout-single-cta]] — 앱 홈은 카드 대신 좌우 끝까지 닿는 구간(면 + 회색 띠)으로 나누고, 채운 버튼은 「오늘의 세트 풀기」 하나만 둔다 (다른 탭은 카드 유지)
- [[DEC-0190-exam-dday-in-top-bar]] — 앱 홈의 시험 일정 카드를 없애고 상단 바 로고 자리에 시험 D-day를 둔다
- [[DEC-0191-home-order-readiness-then-daily-set]] — 앱 홈 순서는 합격 준비도(내 상태) → 오늘의 세트(행동) → 출제 경향 → 추천 → 학습 현황 → 광고 → 공부 팁 → 토론
- [[DEC-0192-readiness-activity-rings]] — 앱 홈 합격 준비도는 겹친 링 3개(정확도·범위·최신성) + 범례로, 색은 기존 앱 토큰
- [[DEC-0204-profile-drops-info-shown-elsewhere]] — 앱 프로필 탭은 "내 기록을 보는 곳" — 다른 탭에 이미 있는 정보는 빼고 내 상태 > AI 분석 > 영역별 정답률 > 광고 순으로 둔다

## 대체된 결정 (역사)
- 없음

## 관련 이슈
- [[ISS-0019-exam-schedule-domain-api]] (resolved, GitHub #23) — SQLD/SQLP Exam Schedule 도메인 및 시험 일정 관리 API
- [[ISS-0020-home-greeting-api]] (resolved, GitHub #24) — 홈 화면 인사말 API (Greeting)
- [[ISS-0023-random-question-recommendations-api]] (resolved, GitHub #27) — 랜덤 추천 문제 API (Question Recommendations)
- [[ISS-0031-daily-study-heatmap-api]] (resolved, GitHub #42) — 날짜별 학습 기록 히트맵 API
- [[ISS-0035-replace-progress-with-readiness]] (resolved, GitHub #52) — 홈 진도율을 합격 준비도(Readiness)로 대체
- [[ISS-0036-greeting-response-schema-split]] (resolved, GitHub #53) — 홈 인사말 응답이 닉네임·본문·이모지를 한 문자열로 내려주고 D-day 구간엔 긴급 메시지만 반복
- [[ISS-0040-home-screen-api-integration]] (resolved, GitHub #67) — 홈 화면 미연동 API 6개 연동 명세
- [[ISS-0057-fe-hardcoded-analysis-to-api]] (resolved, GitHub #101) — 프론트 분석 데이터 하드코딩과 UI 개선 필요
- [[ISS-0060-daily-challenge-result-ux]] (resolved, GitHub #106) — 오늘의 문제 풀이·결과 화면 UX — 정답 오표시, 부적절한 버튼, 완료 카드 미반영
- [[ISS-0065-heatmap-tooltip-streak-icon]] (resolved, GitHub #113) — 홈 학습 현황 툴팁 부재와 연속 N일 불꽃 아이콘 강조 부족
- [[ISS-0072-home-single-api-failure-full-fallback]] (resolved, GitHub #123) — 홈 API 하나만 실패해도 홈 전체가 ErrorFallback으로 교체
- [[ISS-0077-home-today-recommend-stale-after-submit]] (resolved, GitHub #134) — 문제 풀이 후 홈의 오늘의 문제·추천 문제 상태가 즉시 갱신되지 않음
- [[ISS-0085-ai-question-terminology-sparkles]] (resolved, GitHub #149) — 서비스 전반 "문제" → "AI문제" 용어 통일 및 Sparkles 아이콘
- [[ISS-0087-mobile-header-team-modal]] (resolved, GitHub #157) — 모바일 홈 상단 헤더 및 팀 모달 구현
- [[ISS-0088-home-greeting-linebreak-fadein]] (resolved, GitHub #158) — 홈 Greeting 메시지 줄바꿈, 닉네임 강조, 페이드인 애니메이션
- [[ISS-0089-apply-144-pattern-daily-recommend]] (resolved, GitHub #159) — 데일리 챌린지·추천 문제에 #144 UI/UX 패턴 적용
- [[ISS-0091-stagger-fadein-tab-sections]] (resolved, GitHub #162) — 홈 및 탭 전환 시 섹션별 스태거 페이드인 애니메이션
- [[ISS-0092-home-daisyui-pilot]] (resolved, GitHub #167) — Home.tsx daisyUI 컴포넌트 클래스 적용 (파일럿)
- [[ISS-0095-recommend-refresh-button-fadein]] (resolved, GitHub #174) — AI 추천문제 새로고침 버튼 및 카드 페이드인 애니메이션
- [[ISS-0102-home-exam-card-dday-emphasis]] (resolved, GitHub #184) — 홈 시험 일정 카드 D-day 강조와 배치 순서 변경
- [[ISS-0109-heatmap-not-refreshed-after-submit]] (resolved, GitHub #194) — 문제 풀이 후 홈 학습 현황(heatmap)·streak이 즉시 갱신되지 않음
- [[ISS-0134-rag-personalized-recommendation]] (resolved, GitHub #248) — 문제 추천이 완전 랜덤이라 풀이 기록이 반영되지 않음
- [[ISS-0137-home-recommendation-missing-member-uuid]] (resolved, GitHub #253) — 홈 AI 추천이 오답 기록과 무관하게 항상 랜덤
- [[ISS-0153-recommendation-refresh-session-dedupe]] (resolved, GitHub #284) — 홈 AI 추천 새로고침을 눌러도 같은 문제가 나옴
- [[ISS-0155-heatmap-stale-after-solving]] (resolved, GitHub #290) — 문제 풀이 후 홈 복귀 시 학습현황 캘린더가 즉시 갱신되지 않음
- [[ISS-0156-recommendation-exclude-uuids-header-overflow]] (resolved, GitHub #291) — 홈 추천 새로고침 반복 시 `excludeQuestionUuids` 누적으로 Tomcat 헤더 한도 초과 → 400
- [[ISS-0158-home-recommendation-api-infinite-loop]] (resolved, GitHub #298) — 홈 진입 시 추천 문제 API가 무한 반복 호출됨
- [[ISS-0159-recommendation-skeleton-loading]] (resolved, GitHub #301) — 홈 AI 추천문제 초기 로딩 중 섹션이 숨겨져 레이아웃 점프
- [[ISS-0164-home-section-title-css-unify]] (resolved, GitHub #307) — 홈 섹션 타이틀 CSS 통일 및 에러 상태 제목 누락
- [[ISS-0178-app-recommendation-single-solve]] (resolved, GitHub #333) — 앱 추천 문제 단건 풀이 모드
- [[ISS-0194-home-exam-schedule-past-round]] (resolved, GitHub #349) — 홈 시험 일정에 지난 회차(D+129)가 표시됨
- [[ISS-0203-odd-one-out-choice-gen-fails]] (resolved, GitHub #358) — 추천 문제 ODD_ONE_OUT 선택지 생성이 37초 뒤 실패함
- [[ISS-0220-app-offline-shows-empty-data]] (resolved, GitHub #375) — 서버 연결 실패 시 앱 홈·통계가 오류 대신 빈 데이터로 보임
- [[ISS-0232-web-home-cards-failure-as-empty]] (resolved, GitHub #399) — 웹 홈 카드가 API 실패를 빈 데이터로 표시함
- [[ISS-0243-selected-exam-schedule-past-dday-plus]] (resolved, GitHub #411) — 선택된 시험 일정이 지난 제61회로 남아 홈 D-day가 D+로 표시
- [[ISS-0289-refresh-home-daily-set-on-resume]] (resolved, GitHub #483) — 앱 복귀나 날짜 변경 시 홈·오늘의 세트가 갱신되지 않음
- [[ISS-0320-ads-cards-notification-sheet-home]] (resolved, GitHub #522) — 하단 상시 광고 제거, 광고 카드화, 알림 권한 시트와 홈 카드 정리
- [[ISS-0321-latest-trend-notice-badge]] (resolved, GitHub #523) — 2026 출제 경향 반영 업데이트 공지와 최신 경향 표시
- [[ISS-0326-home-top-bar-redesign]] (resolved, GitHub #530) — 홈 상단 재설계 — 로고·알림 버튼 상단 바, 잘리는 환영 문구
- [[ISS-0356-home-questions-tab-restructure]] (resolved, GitHub #574) — 홈, 문제 탭 재구성 — 출제 경향 분리 및 오답 노트 이동 (이후 앱 전체 발견성·접근성 개편으로 확장)
- [[ISS-0363-app-wide-ui-ux-cleanup]] (resolved, GitHub #602) — 앱 전체 UI/UX 정리 — 화면별 검수 결과와 개선안(기기 크기 대응 포함)
- [[ISS-0395-home-countdown-badge-cleanup]] (resolved, GitHub #648) — 홈 첫 화면 인사 아래 시험 카운트다운 보조 문구가 시험 일정 카드와 겹침 (앱)
- [[ISS-0405-home-first-load-skeleton-wait]] (resolved, GitHub #676) — 홈 첫 로딩 대기 시간 단축 — 지난 데이터 먼저 보여 주기
- [[ISS-0413-app-home-ui-ux-redesign]] (resolved, GitHub #701) — 앱 홈 화면 UI/UX 개편
