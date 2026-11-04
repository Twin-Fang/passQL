---
type: decision
id: DEC-0243
created: 2026-11-04
reviewed: null
topics: [design-system, billing, auth-member]
status: active
supersedes: DEC-0208
superseded_by: null
related: ["[[ISS-0448-mypage-account-pass-area-promo-code]]", "[[ISS-0448-mypage-account-pass-area-promo-code-report]]", "[[DEC-0208-pass-ticket-fields-unified]]", "[[DEC-0207-pass-ticket-upright-float-shadow]]", "[[DEC-0212-keep-benefit-icon-row-in-ticket]]", "[[DEC-0204-profile-drops-info-shown-elsewhere]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[ISS-0428-app-profile-tab-redesign-report]]"]
---

# DEC-0243: 프로필 상단은 A안(카드형) — 계정 줄 + 무료는 탑승권 대신 "오늘 남은 문제"·업그레이드 배너, 프로는 남은 날 큰 숫자의 PRO 탑승권 카드(승객 · 만료일 · 이용권) + 이어서 연장

## 문제 정의 (Context)
#749 개편([[ISS-0428-app-profile-tab-redesign-report]]) 뒤 프로필 상단 이용권 자리는 탑승권 하나였다(무료 회색 탑승권 + 사용량 게이지, 프로 보라 탑승권). 프로 탑승권 칸은 정보 시트와 같게 승객 · 남은 날 · 시험일로 통일돼 있었다 ([[DEC-0208-pass-ticket-fields-unified]]). 이 구조로는 로그인 방법·회원 번호·가입일·구매 내역, 무료 회원의 오늘 남은 문제와 보너스를 보여 줄 자리가 없었다 (GitHub #816, 사용자: "기반이 너무 없다").

## 결정 (Decision)
2026-11-04 사용자가 시안 3안 중 **A안(카드형)**을 골랐다 ("A안이 젤 깔끔하고좋네").
- **첫 구간 순서:** 계정 줄(닉네임 + 로그인 방법 배지 + 가입일, `관리` > `/account` 계정·이용권 화면) > 내 정답률 큰 숫자 > 이용권 자리. 계정 줄은 이용권 자리 밖이라 결제 스위치와 무관하게 항상 보인다.
- **무료 이용권 자리:** 탑승권을 두지 않는다. "오늘 남은 문제" 큰 숫자 + 게이지 + 보너스 3칸(세트 완료·정답률·광고 남은 횟수, [[DEC-0239-free-daily-limit-bonus-three-kinds]]) > 업그레이드 배너(시험 D-day · 할인율 · 정가 줄긋기 · 하루 가격) > 구매 복원·프로모션 코드 행.
- **프로 이용권 자리:** 보라 PRO 탑승권 카드 — 남은 날을 큰 숫자(`N 일 남았어요`)로, 정보 칸은 승객 · 만료일 · 이용권(이름), 시험(자격 + 회차)은 목적지 자리, 떼는 칸 "사용 중", 혜택 아이콘 줄 유지. 그 아래 이어서 연장 카드(할인 표시) > 구매 내역·구매 복원·프로모션 코드 행.
- **결제 표시 꺼짐·등급 모름:** 이용권 자리째 없다 ([[DEC-0005-ship-with-billing-switch-off]]).
- **DEC-0208 중 바뀌는 것:** 프로필 프로 탑승권은 더 이상 정보 시트와 같은 칸(승객 · 남은 날 · 시험일)을 쓰지 않는다. 프로필 탑승권과 정보 시트 탑승권의 칸 통일 규칙을 이 결정이 대체한다.
- **그대로인 것:** 이용권 정보 시트 탑승권은 승객 · 남은 날 · 시험일 + 떼는 칸 "사용 중"을 유지하고, 떼는 칸 바코드 폭은 그 아래 글자 폭에 맞춘다(탑승권 컴포넌트 규칙). PRO 탑승권은 프로 프로필 카드와 이용권 구매 시트 미리보기에서 계속 쓴다. 시트 탑승권 정방향·띄움 그림자([[DEC-0207-pass-ticket-upright-float-shadow]])와 탑승권 안 혜택 아이콘 줄([[DEC-0212-keep-benefit-icon-row-in-ticket]])은 A안이 건드리지 않아 그대로 유효하다.

## 검토한 대안 (Alternatives)
- **B안 (탑승권 중심):** 지금 탑승권 구조를 키우는 안. 사용자가 A안을 골랐고, B안을 고르지 않은 이유는 "A안이 젤 깔끔" 외에 기록되지 않았다.
- **C안 (설정형 목록):** 같은 이유로 고르지 않았다 (그 밖의 논의 기록 없음).

## 결과 (Consequences)
**긍정**
- 계정 상태(로그인 방법·가입일·회원 번호·구매 내역)를 프로필과 `/account`에서 한 번에 확인할 수 있다.
- 무료 회원이 오늘 남은 문제와 보너스를 한눈에 보고, 업그레이드 배너가 할인·하루 가격을 보여 준다.

**부정**
- 무료 회원은 프로필에서 흐린 혜택 아이콘이 든 회색 무료 탑승권을 더 보지 않는다. 혜택 아이콘 줄은 구매 시트의 PRO 탑승권 미리보기(떼는 칸 "PRO")에서 본다. DEC-0212가 적은 "무료 회원에게 못 받는 혜택을 보여 주는 장치"는 이제 그 미리보기가 맡는다.
- 프로필 탑승권과 정보 시트 탑승권의 칸이 다시 달라졌다.
- 프로 카드가 보이면 구매 직후 연출 대기 표시를 지워, 회색 탑승권이 보라로 차오르는 프로필 연출은 없다 (코드 주석 기준).
- 쓰이지 않게 된 `profile_pass_slot.dart`와 그 테스트가 남아 있다.

## 영향 범위 (Scope)
앱 `widgets/profile/profile_status_section.dart`, `profile_plan_area.dart`, `profile_account_row.dart`, `profile_today_free_usage.dart`, `profile_upgrade_banner.dart`, `profile_pro_pass_card.dart`, `profile_pro_extend_card.dart`, `profile_plan_action_rows.dart`, `/account` 라우트(`router/app_routes.dart`, `app_router.dart`). 서버 `GET /api/members/me`(`maskedEmail`, `memberCode`), `GET /api/members/me/purchases`.

## 출처 (References)
- GitHub #816 이슈 본문(시안 A·B·C), 리포트 (2026-11-04), PR #822
- 사용자 선택 (2026-11-04 대화, "A안이 젤 깔끔하고좋네")
- 이슈: [[ISS-0448-mypage-account-pass-area-promo-code]], 리포트 [[ISS-0448-mypage-account-pass-area-promo-code-report]]
