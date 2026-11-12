---
type: decision
id: DEC-0287
created: 2026-11-12
reviewed: null
topics: [billing, practice, ads, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0490-credit-term-purchase-funnel-events]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]", "[[DEC-0283-daily-limit-view-reward-first]]"]
---

# DEC-0287: 무료 한도는 `크레딧`으로 부르고, 잔액은 탭 화면 상단 바의 아이콘 + 숫자 한 곳에 두며 누르면 받는 방법과 이용권이 한 시트에 나온다

## 문제 정의 (Context)
사용자가 "오늘 남은 문제는 보통 어디에서 보여 주냐", "위에서 바로 구매하고 싶으면 구매할 수 있어야", "크레딧이라는 표현을 쓰고 크레딧 에셋을 하나 만들면 더 예쁠 것", "정보가 덕지덕지 많다", "대기업이 하는 방식을 그대로"라고 했다 (GitHub #966, #971).

## 결정 (Decision)
- 무료 랜덤 풀이 한도를 `크레딧`으로 부른다 (랜덤 풀기 1문제 = 크레딧 1개). "남은 문제", "문제 더 받기", "+N문제"를 쓰지 않는다. 오늘의 세트는 크레딧을 쓰지 않는다.
- 크레딧 아이콘(번개 동전) 에셋 하나를 `PassqlCreditIcon` 으로만 쓴다.
- 잔액은 탭 화면 상단 바 오른쪽 알약(아이콘 + 숫자, FREE 칩 자리)에 둔다. 누르면 크레딧 시트: 잔액 머리(큰 숫자, 보너스 구간이 초록인 게이지) > PRO 주 버튼 > 광고 > 오늘의 세트. 목록 행 오른쪽의 남은 수 글자·보너스 칩은 없앤다.
- 한도 화면의 주 버튼은 이용권이다. [[DEC-0283-daily-limit-view-reward-first]]의 "이용권은 맨 아래 plain 한 줄"을 이 부분만 바꾼다(광고·세트 카드는 유지).
- 프로필 오늘 크레딧에는 오늘 내역(받은 것·쓴 것) 시트를 둔다. 서버의 오늘 집계로 만들며 지난 날짜 내역은 없다.
- 홈 상단 바 왼쪽은 로고 + 시험 D-day 배지, 인사말의 "시험이 얼마 남지 않았어요" 태그는 뺀다. 탭 첫 화면 제목은 오른쪽 요소와 같은 줄에 둔다.
- 상태는 글자("받았어요", "오늘은 받지 못했어요") 대신 아이콘과 색으로 보인다.

## 검토한 대안 (Alternatives)
- 남은 수를 목록 행 오른쪽 글자로 유지: 흔한 방식이 아니고 정보가 겹쳐 버렸다.
- 크레딧 아이콘 후보 A(반짝임 동전): 작은 크기에서 반짝임이 안 보여 B(번개 동전)를 골랐다.
- 날짜별 크레딧 내역: 서버 기록 테이블이 필요해 이번에는 오늘 내역만.

## 결과 (Consequences)
**긍정**
- 한도와 보상이 한 단어·한 아이콘으로 모이고, 어느 탭에서든 잔액과 구매 입구가 보인다.

**부정**
- 상단의 FREE 칩이 없어져 이용권 시트로 바로 가는 입구가 한 단계 늘었다(알약 > 크레딧 시트 > PRO 버튼).
- 서버 오류 문구(`FREE_DAILY_LIMIT_REACHED` 메시지)는 서버 쪽 표현이 따로라, 앱은 앱 문구로 덮어 보인다.

## 영향 범위 (Scope)
- 앱: `widgets/practice/`(`remaining_solves_pill`, `credit_gauge`, `credit_balance_header`, `daily_limit_reward_view`, `daily_limit_daily_set_card`), `widgets/profile/`(`profile_today_free_usage`, `profile_bonus_cards`, `credit_today_history*`), `widgets/pro/pro_plan_chip_slot.dart`, `widgets/chapter/chapter_app_bar.dart`, `widgets/home/`, `design/components/passql_credit_icon.dart`·`passql_large_title_scroll_view.dart`, 자산 `app/assets/credit.png`.
- 문서: `app/.claude/rules/Design.md` 5장 화면 원칙.

## 출처 (References)
- GitHub #966, #971: https://github.com/Twin-Fang/passQL/issues/971
