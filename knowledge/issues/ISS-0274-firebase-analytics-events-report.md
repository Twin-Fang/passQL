---
type: completion-report
id: ISS-0274
created: 2026-10-15
topics: [ops-infra]
status: resolved
resolves: "[[ISS-0274-firebase-analytics-events]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/468"
---

# ISS-0274 완료 리포트: 화면 추적 + 핵심 이벤트 8종, 광고 ID 권한 제거

GitHub #468 구현 보고서(2026-10-15) 기준.

## 해결 방법
- `core/monitoring/analytics_event_names.dart`(이벤트·파라미터 이름 상수), `core/monitoring/app_analytics.dart`(`appAnalyticsProvider`, 디버그 빌드 수집 끔), `router/screen_view_tracker.dart`(`AppRoutes` 패턴 이름으로 `screen_view` — UUID 미포함).
- 이벤트 8종: `login`(`method`), `answer_submitted`(`is_correct`, `topic_name`), `daily_set_completed`(`correct_count`, `question_count`), `chapter_completed`(`topic_code`, `correct_count`, `question_count`), `wrong_notes_opened`, `feedback_sent`, `question_reported`, `ai_explanation_requested`(`explanation_type`). 이메일·닉네임·SQL 답안 원문은 보내지 않는다.
- 후속(`ea27bb1`): 매니페스트에서 광고 ID 권한 제거, 광고 ID 수집 끔.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: `flutter test` 271개, 병합 매니페스트 광고 ID 관련 권한 0개, Play 내부·비공개 재업로드 run `38816644147` 성공.
- 주의(원본): Firebase 프로젝트에 Google Analytics가 연결돼 있어야 수집된다. 광고 ID 권한 제거는 매니페스트 `tools:node="remove"`에 묶여 있어 지우면 Play 업로드가 다시 거부된다. `wrong_notes_opened`는 "다시 시도" 시 한 번 더 기록된다.

## 교훈
(원본에 없음, 볼트 정리) SDK를 추가한 뒤 Play 업로드가 거부되면 병합 매니페스트의 권한(광고 ID 등)이 Play Console 선언과 맞는지 본다.
