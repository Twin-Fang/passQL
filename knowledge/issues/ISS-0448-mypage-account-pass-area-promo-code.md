---
type: issue
id: ISS-0448
created: 2026-11-04
topics: [billing, auth-member, design-system]
symptoms: ["마이페이지 계정 상태 없음", "로그인 방법 확인 불가", "회원 번호 없음", "구매 내역 없음", "오늘 남은 문제 안 보임", "보너스 받은 양 안 보임", "결제 유도 지점 부족", "할인 표시 약함", "하루 가격 없음", "프로모션 코드 입력 없음", "구매 복원만 있음", "기반이 너무 없다", profile_status_section, profile_pass_slot, pro_offer_sheet, "/members/me"]
root_cause: "프로필 상단이 탑승권 하나라 계정 정보·오늘 남은 문제·구매 내역을 보여 줄 자리가 없었고, 결제 유도는 한도 도달·잠긴 기능 두 곳, 보상 수단은 구매 복원뿐이었다"
status: resolved
resolution: "[[ISS-0448-mypage-account-pass-area-promo-code-report]]"
related: ["[[ISS-0448-mypage-account-pass-area-promo-code-report]]", "[[DEC-0243-profile-top-card-style-a]]", "[[DEC-0244-promo-code-store-codes-only]]", "[[DEC-0245-free-limit-daily-reset-kept]]", "[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0443-free-daily-limit-bonus]]", "[[ISS-0444-test-build-dev-tools-overlay]]", "[[ISS-0361-billing-switch-final-checks]]"]
source: "https://github.com/Twin-Fang/passQL/issues/816"
---

# ISS-0448: 마이페이지 계정·이용권 영역과 결제 유도, 할인 표시, 프로모션 코드

GitHub #816 이슈 본문 기준. 원본 사본: `_sources/issues/ISS-0448-mypage-account-pass-area-promo-code.md` (로컬 전용). 완료 리포트: [[ISS-0448-mypage-account-pass-area-promo-code-report]]

## 증상
- 마이페이지에 계정 상태를 확인할 곳이 없다. 로그인 방법(카카오·Apple 등), 회원 번호(문의용), 가입일, 이메일, 이용권 남은 날·만료일, 구매 내역을 한곳에서 볼 수 없다.
- 무료 회원이 "오늘 몇 문제 남았는지, 보너스를 얼마나 받았는지"를 한눈에 알 수 없다 (#808 보너스).
- 결제 유도 지점이 한도 도달·잠긴 기능 두 곳뿐이고, 할인 표시는 이용권 시트 안 리본·줄긋기뿐이다. 하루 가격·시험일 연결 문구가 없다.
- 문제가 생긴 사용자에게 보상할 프로모션 코드 입력이 없다 (구매 복원만 있음).
- 사용자 요청 (2026-11-04): 계정 상태 판단 + 여러 시안 + 결제 유도 많이 + 할인율 표시, "기반이 너무 없다".

## 재현 조건
프로필 탭 상단은 [[ISS-0428-app-profile-tab-redesign]](#749)의 탑승권 구조다. 무료는 회색 탑승권 + 사용량 게이지, 프로는 보라 탑승권.

## 조사 기록
- 2026-11-04: 시안 3안(A 카드형, B 탑승권 중심, C 설정형 목록)과 계정·이용권 화면, 이용권 시트 할인 표시, 결제 유도 지점 6곳(① 결과 화면 ② 홈 D-day 배너 ③ 한도 도달 시트 ④ 통계 약점 잠금 ⑤ 광고 본 직후 ⑥ 설치 후 3일 넉넉한 시작)을 시안 캔버스로 냈다.
- 2026-11-04: 사용자가 A안을 골랐다("A안이 젤 깔끔하고좋네") → [[DEC-0243-profile-top-card-style-a]].
- 2026-11-04: 설계자 판단으로 프로모션 코드는 스토어 코드만 → [[DEC-0244-promo-code-store-codes-only]], 무료 한도 초기화는 하루(KST 0시) 유지 → [[DEC-0245-free-limit-daily-reset-kept]]. ⑥은 서버 한도 규칙 변경이라 별도 결정이 필요하다고 적었다.

## 근본 원인
결함이 아니라 화면·기능 부족. 프로필 상단에 계정·이용량·구매 정보를 둘 구조가 없었다.
