---
type: completion-report
id: ISS-0448
created: 2026-11-04
topics: [billing, auth-member, design-system]
status: resolved
resolves: "[[ISS-0448-mypage-account-pass-area-promo-code]]"
related: ["[[DEC-0243-profile-top-card-style-a]]", "[[DEC-0244-promo-code-store-codes-only]]", "[[DEC-0245-free-limit-daily-reset-kept]]", "[[DEC-0208-pass-ticket-fields-unified]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[ISS-0428-app-profile-tab-redesign-report]]", "[[ISS-0444-test-build-dev-tools-overlay-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/816"
---

# ISS-0448 완료 리포트: 프로필 상단 A안(카드형), 계정·이용권 화면 `/account`, 할인 리본·하루 가격, 스토어 프로모션 코드

GitHub #816 리포트 기준 (2026-11-04). 원본 사본: `_sources/issues/ISS-0448-mypage-account-pass-area-promo-code-report.md` (로컬 전용).

> 머지 상태: 작성 시점(2026-11-04)에 PR #822는 미머지다. 이 노트는 PR #822와 같이 머지되고 다음 릴리스에 배포된다.

## 해결 방법
### 서버
- `GET /api/members/me`: `maskedEmail`(앞 2자 + `***` + 도메인, 없으면 null), `memberCode`(`PQL-` + 회원 UUID 앞 8자리, 로그의 회원 ID와 같은 앞자리라 문의 때 바로 찾음).
- `GET /api/members/me/purchases` (신규): 스토어 구매 + 운영 지급(관리자 부여 감사 기록 최근 50건) 최신순. 구매 토큰·주문 번호·지급 사유는 내보내지 않는다.
- `EmailMasking`(테스트 포함), `MemberPurchaseHistoryService`(테스트 포함), API 계약·웹 타입 갱신.

### 앱
- **프로필 상단 A안** → [[DEC-0243-profile-top-card-style-a]]: 계정 줄, 무료 "오늘 남은 문제" 큰 숫자·게이지·보너스 3칸, 업그레이드 배너(시험 D-day·할인율·정가 줄긋기·하루 가격), 프로 탑승권·이어서 연장, 구매 내역·구매 복원·프로모션 코드 행 (`profile_plan_area.dart`, `profile_account_row.dart`, `profile_today_free_usage.dart`, `profile_upgrade_banner.dart`, `profile_pro_pass_card.dart`, `profile_pro_extend_card.dart`, `profile_plan_action_rows.dart`).
- **계정·이용권 화면 `/account`:** 로그인 방법, 가린 이메일, 회원 번호 복사, 가입일, 지금 등급, 구매 내역, 구매 복원, 스토어 코드 입력, 설정 연결.
- **프로모션 코드** → [[DEC-0244-promo-code-store-codes-only]]: iOS App Store 오퍼 코드 시트, Android Play 코드 입력 링크. 스토어 호출은 결제 포트 계층 안에만 둔다.
- **이용권 시트:** 할인이 가장 큰 칸에 `N% 할인 · 가장 많이 골라요` 리본, 모든 칸에 하루 가격. 하루 가격은 1원 단위 반올림 — 10원 단위로 내리면 1개월권이 140원으로 실제보다 싸 보인다.
- **광고 보너스 뒤** 토스트 `광고 없이 풀기` > 이용권 시트 (결제 유도 ⑤).
- **개발자 도구** `결제 켜짐 흉내 (무료, 한도 없음)`.
- 결제 스위치가 꺼진 지금은 결제 관련 표시는 숨겨지고 계정 정보만 바로 보인다 ([[DEC-0005-ship-with-billing-switch-off]]).

### 검증
- 앱 analyze 0, 테스트 101 통과, 서버 테스트 통과, 웹 타입 검사 통과.
- iOS 시뮬레이터(운영 서버 + 개발자 도구): 서버값 계정 줄, 결제 켜짐 흉내 무료 화면, 프로 강제 화면, 계정·이용권 화면 확인. 새 서버 API 배포 전이라 이메일·회원 번호는 비고, 구매 내역은 "다시 시도"로 처리됐다.
- 시뮬레이터에는 스토어 상품이 없어 할인·가격 부분은 숨김으로만 확인했다 (실기기 테스트 빌드에서 확인 필요).

## 근본 원인 (확정)
결함이 아니라 화면·기능 부족. 프로필 상단에 계정·이용량·구매 정보를 둘 구조와 보상 수단(프로모션 코드)이 없었다.

## 재발 방지
- 무료 한도 초기화 기준은 하루(KST 0시) 유지 → [[DEC-0245-free-limit-daily-reset-kept]].

## 알고 남긴 것
- 하지 않은 것: 결과 화면 유도 ①, 홈 D-day 배너 ②, 설치 후 3일 넉넉한 시작 ⑥(서버 한도 규칙 변경 필요), 이용권 시트 "어느 시험까지" 문구.
- 쓰이지 않게 된 `profile_pass_slot.dart`와 그 테스트는 지우지 않고 남겨 뒀다.
- iOS 코드 시트 적용 결과는 구매 스트림으로만 반영되고, Android는 앱으로 돌아올 때 갱신에 기댄다.

## 교훈
(원본의 핵심 구현에서 정리)
- 가격을 사람이 읽기 좋게 줄일 때는 반올림 방향이 상품 간 비교를 왜곡하지 않는지 본다 (10원 내림은 1개월권을 싸 보이게 했다).
