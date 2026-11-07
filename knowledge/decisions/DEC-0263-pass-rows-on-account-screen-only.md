---
type: decision
id: DEC-0263
created: 2026-11-07
reviewed: null
topics: [design-system, billing, auth-member]
status: superseded
supersedes: DEC-0243
superseded_by: DEC-0276
related: ["[[ISS-0461-plan-aligned-options-new-choices-mode]]", "[[ISS-0461-plan-aligned-options-new-choices-mode-report]]", "[[DEC-0243-profile-top-card-style-a]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[DEC-0207-pass-ticket-upright-float-shadow]]", "[[DEC-0212-keep-benefit-icon-row-in-ticket]]"]
---

# DEC-0263: 프로필 상단은 A안(카드형)을 유지하되, 구매 내역·구매 복원·프로모션 코드 행은 계정·이용권 화면(`/account`) 한 곳에만 두고 프로필에는 "이용권 관리" 한 줄만 남긴다

## 문제 정의 (Context)
[[DEC-0243-profile-top-card-style-a]] 는 프로필 이용권 자리 아래에 구매 복원·프로모션 코드(무료), 구매 내역·구매 복원·프로모션 코드(프로) 행을 두었다. 같은 행이 계정·이용권 화면에도 있어 두 곳에 중복됐다 (GitHub #863, [[ISS-0461-plan-aligned-options-new-choices-mode]]). 리포트가 "DEC-0243(이용권 행 정리)의 후속 결정"을 남기라고 적었다.

## 결정 (Decision)
- **바뀌는 것:** 구매 내역·구매 복원·프로모션 코드 행은 계정·이용권 화면(`/account`) 한 곳. 프로필 이용권 자리에는 "이용권 관리" 한 줄(진입 링크)만.
- **닉네임:** 프로필 닉네임 줄에 연필 아이콘(누를 수 있음 표시), 계정 화면에도 닉네임 행을 두어 그곳에서도 변경.
- **그대로인 것 (DEC-0243 A안에서 이어받음):**
  - 첫 구간 순서: 계정 줄(닉네임 + 로그인 방법 배지 + 가입일, `관리` > `/account`) > 내 정답률 큰 숫자 > 이용권 자리. 계정 줄은 결제 스위치와 무관하게 항상 보인다.
  - 무료 이용권 자리: 탑승권 없이 "오늘 남은 문제" 큰 숫자 + 게이지 + 보너스 3칸([[DEC-0239-free-daily-limit-bonus-three-kinds]]) > 업그레이드 배너.
  - 프로 이용권 자리: 보라 PRO 탑승권 카드(남은 날 큰 숫자, 승객 · 만료일 · 이용권, 목적지 자리에 시험, 떼는 칸 "사용 중", 혜택 아이콘 줄) > 이어서 연장 카드.
  - 결제 표시 꺼짐·등급 모름이면 이용권 자리째 없다 ([[DEC-0005-ship-with-billing-switch-off]]).
  - 이용권 정보 시트 탑승권은 승객 · 남은 날 · 시험일 + "사용 중" 유지. 시트 탑승권 정방향·띄움 그림자([[DEC-0207-pass-ticket-upright-float-shadow]]), 탑승권 안 혜택 아이콘 줄([[DEC-0212-keep-benefit-icon-row-in-ticket]]) 유지.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문 제안: "이용권 관련 행은 한 곳으로 모으고 다른 곳은 진입 링크만".)

## 결과 (Consequences)
**긍정**
- 같은 행이 두 곳에 있어 생기던 혼란이 사라지고, 이용권 관리가 한 화면에 모인다.

**부정**
- 프로필에서 구매 복원·프로모션 코드까지 한 번 더 들어가야 한다 (원본에 언급 없음, 구조상 결과).

## 영향 범위 (Scope)
앱 `widgets/profile/profile_plan_area.dart`, `profile_plan_manage_row.dart`(신규 "이용권 관리" 줄), `profile_account_row.dart`, `widgets/account/account_info_section.dart`. `profile_plan_action_rows.dart` 는 삭제.

## 출처 (References)
- GitHub #863 이슈 본문·리포트 댓글 (2026-11-07), 커밋 85727f0b
- 대체 대상: [[DEC-0243-profile-top-card-style-a]] (A안 선택 근거는 그 노트의 #816 기록)
