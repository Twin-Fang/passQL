---
type: completion-report
id: ISS-0428
created: 2026-10-29
topics: [progress-stats, billing, design-system]
status: resolved
resolves: "[[ISS-0428-app-profile-tab-redesign]]"
related: ["[[DEC-0204-profile-drops-info-shown-elsewhere]]", "[[DEC-0205-pro-benefits-single-source]]", "[[DEC-0206-topic-accuracy-list-with-octagon-chart]]", "[[DEC-0004-free-pro-feature-boundary]]"]
source: "https://github.com/Twin-Fang/passQL/issues/749"
---

# ISS-0428 완료 리포트: 프로필 탭을 구간 + 회색 띠 구조와 passQL PASS 탑승권으로 개편

GitHub #749 리포트 댓글 기준 (2026-10-29, `## 개요` 형식).

## 해결 방법
- 탭 이름을 "내 프로필"에서 **프로필**로 바꿨다 (`widgets/app_shell.dart`). 정보 위계는 내 상태 > AI 분석 > 영역별 정답률 > 광고.
- 홈·문제 탭에 이미 있는 정보(합격 준비도, 히트맵, 오답 노트 행, 순위 행)를 뺐다 → [[DEC-0204-profile-drops-info-shown-elsewhere]]. 히트맵·오늘의 세트 묶음(`homeLearningStatusProvider`)을 더 부르지 않아 `/progress` 중복 호출이 없어졌다.
- 탑승권 컴포넌트 `design/components/passql_pass_ticket.dart`(신규): 본문 + 절취선 + 떼는 칸(바코드). 무료 회색, 프로 보라 그라데이션. 빛줄기·홀로그램·기울기, 동작 줄이기면 효과 정지. 프로필·구매 시트·정보 시트 3곳이 쓴다. 무료 사용량 게이지 `passql_pass_usage_gauge.dart`(신규).
- 혜택 목록을 비교표 행에서 `widgets/pro/pro_benefits.dart`(신규) 하나로 옮겼다 → [[DEC-0205-pro-benefits-single-source]].
- 영역별 정답률: 레이더·막대 두 장을 목록 하나로 합치고 같은 자리에서 8각 차트로 전환 → [[DEC-0206-topic-accuracy-list-with-octagon-chart]]. `pubspec.yaml`에서 `fl_chart` 제거.
- 이용권 구매 시트(`pro_offer_sheet.dart`)와 정보 시트(`pro_info_sheet.dart`)를 문장 제목·내 이름 탑승권·혜택 줄로 바꿨다. 구매 시트는 모든 진입점(홈 랜덤 풀기, 오답 노트, 풀이 모드 등) 공용 한 장이라 함께 적용된다. 혜택 강조는 기존 `reason`과 별도 선택 인자 `focusedBenefitIndex`.
- 화면 숫자는 모두 지금 API 값의 계산이다: "시험까지 랜덤 최대 N문제" = 남은 날 × 무료 하루 한도, "오늘 N문제 더 풀었어요" = 오늘 랜덤 풀이 수 − 한도, "3,300원 아껴요" = 1개월 가격 × 3 − 3개월 가격, 할인 %·월 환산은 기존 `pass_discount.dart`. 값이 없으면 그 줄을 빼거나 다른 문장으로 바꾼다.
- 무료 영역 목록은 잠금 유지. 리포트: "무엇을 PRO 혜택으로 둘지는 요금제 결정이라 화면 개편에서 바꾸지 않았다." 무료는 `topic-analysis`를 부르지 않고 이름·타일만, 값 자리는 회색 막대(화면 코드에서 블러는 규칙상 쓸 수 없음). 경계 자체는 [[DEC-0004-free-pro-feature-boundary]].
- 구매 직후 연출: 구매 성공 시 기기에 "연출 대기"를 남기고 다음 프로필 진입 때 회색 탑승권이 보라로 차오르며 홀로그램 한 번.
- 시험 D-day와 이용권 남은 날이 같은 기준으로 세도록 `widgets/home/exam_dday.dart`에서 `daysUntilDate`를 떼어 냄. 시험 일정만 받는 `examScheduleProvider`를 홈과 공유.
- 삭제: `summary_stats_section`, `radar_chart_section`, `bar_chart_section`, `stats_shortcut_section`, `stats_empty_state_card`, `profile_section`, `profile_card`, `pro_settings_card`, `pro_plan_comparison_table`, `StatsLockedSample`.

검증: `flutter analyze` 문제 없음, `flutter test` 92개 통과. 브랜치 전체 코드 리뷰 3건(구매 직후 연출 뒤 탑승권이 접히던 것, 홈 당겨서 새로고침이 공유 시험 일정을 다시 받지 않던 것, 큰 글자에서 구매 시트 혜택 줄 넘침)을 테스트 먼저 쓰고 고침. 시뮬레이터(iPhone 16 Pro) 라이트·다크 확인 중 프로 접힌 줄의 PRO 칩이 보라 바탕에 묻히는 문제를 흰 칩으로 고침.

## 근본 원인 (확정)
결함이 아니라 화면 구조 개편. 이슈 본문이 문제로 적은 것은 홈과 겹치는 정보와 카드 10장 구조다.

## 재발 방지
리포트의 "건드리면 위험한 곳":
- `pro_offer_sheet.dart`는 모든 진입점이 쓴다. 바꾸면 홈 랜덤 풀기, 오답 노트, 풀이 모드 진입 시트가 함께 바뀐다.
- `pro_benefits.dart`의 순서는 탑승권 아이콘 순서이자 `focusedBenefitIndex` 기준(영역 잠금 줄은 5번 통계를 강조). 순서를 바꾸면 강조 혜택이 달라진다.
- `examScheduleProvider`는 홈 상단 바와 프로필이 공유. 홈 개요(`homeOverviewProvider`)가 이것을 읽도록 바꿔, 인사말과 시험 일정이 둘 다 실패해도 홈 개요가 오류 대신 빈 값이 된다.
- 약한 영역 기준 60%는 `topic_accuracy_rows.dart`의 `weakAccuracyThreshold` 하나다 (목록 빨강, 차트 꼭짓점·이름 빨강, 차트 점선 공용).

화면으로 확인하지 못한 것: 구매 직후 차오름 연출(시뮬레이터에서 실제 결제 불가), 결제 꺼짐 계정·시험 일정 없음·푼 문제 0개 화면(코드 분기와 계산 테스트로만 확인), 프로 접힌 한 줄(영상에 없음).

후속 후보(리포트): 홈 `ReadinessCard`·`HeatmapWidget`·`SectionOrCard`의 카드형(`isSection: false`) 분기 미사용, 누적 혜택 숫자(서버 기간 누적 풀이 수 필요), 오답 노트를 이용권 비교표에 넣을지(요금제 표시 결정), 동작 줄이기·0%에서도 게이지 애니메이션이 계속 돎, 일부 상품만 가격을 읽으면 할인 기준이 바뀜, 홈을 열기 전에 시트를 열면 시험 정보가 빠짐, 접힘·연출 대기가 계정 구분 없이 기기에 저장됨, 혜택 아이콘 누르는 영역 22pt.

## 교훈
(원본에 없음, 볼트 정리) 이용권 구매 시트·혜택 목록·약한 영역 기준은 각각 한 곳(`pro_offer_sheet.dart`, `pro_benefits.dart`, `weakAccuracyThreshold`)이 여러 화면을 움직인다. 한 화면만 고치려다 다른 진입점이 바뀌지 않는지 먼저 본다.
