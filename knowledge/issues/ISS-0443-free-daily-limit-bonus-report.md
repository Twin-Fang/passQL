---
type: completion-report
id: ISS-0443
created: 2026-11-04
topics: [billing, ads]
status: resolved
resolves: "[[ISS-0443-free-daily-limit-bonus]]"
related: ["[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[ISS-0361-billing-switch-final-checks]]", "[[ISS-0442-app-open-ad-interstitial-cap-relax-report]]", "[[ISS-0444-test-build-dev-tools-overlay-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/808"
---

# ISS-0443 완료 리포트: 무료 랜덤 풀기 한도를 기본 10 + 보너스 3종(최대 30)으로

GitHub #808 리포트 댓글 기준 (2026-11-04). 원본 사본: `_sources/issues/ISS-0443-free-daily-limit-bonus-report.md` (로컬 전용).

> 머지 상태: 작성 시점(2026-11-04)에 미머지·미배포. 커밋은 `aeac4923`(서버), `8ec14dcd`(앱), `5eb1588a`(리뷰 수정)이고 #787 브랜치 위에 쌓였다. 이 노트는 그 코드 PR과 같이 들어간다.

## 해결 방법
- **규칙:** 기본 10 + 완료 +5(오늘의 세트 완료 기록 + 오늘 배정 문제 전부 제출) + 정답률 +5(오늘의 세트 맞힌 수 80% 이상, 5문제면 4개) + 광고 +5 × 하루 2회. 무료 최대 30. 자세한 기준은 [[DEC-0239-free-daily-limit-bonus-three-kinds]].
- **서버 판정:** `PQL-Application/.../entitlement/DailyFreeBonusRule.java`(순수 계산, 정답률은 `맞힌 수 × 100 >= 배정 수 × 80`), `DailyFreeBonusReader.java`(재료 수집, KST), `DailyFreeBonus.java`, `DailyFreeBonusInput.java`.
- **`FeatureAccessPolicy`:** 문제 열기 한도를 "기본 + 보너스"로 비교하고, 광고 보너스 받기(`grantAdBonus`)와 등급 응답 반영을 맡는다.
- **응답:** `MemberPlanResponse`에 `todayFreeLimit`(오늘 유효 한도), `dailyBonus` 추가. `dailyFreeLimit`은 기본 10 그대로(이용권 혜택 비교 `하루 10개`, 이용권 가치 계산이 이 값을 씀).
- **광고 보너스 저장:** `PQL-Domain-Member`의 `MemberDailyAdBonus`, `MemberDailyAdBonusRepository`, `V1_72_2__member_daily_ad_bonus.sql`(회원·날짜·칸 unique). 동시 요청이 같은 칸을 잡으면 횟수를 다시 읽어 한 번 더 시도하고, 그래서 바깥 트랜잭션을 일부러 걸지 않았다.
- **API:** `POST /api/members/me/plan/ad-bonus`. 오늘 2회를 다 쓰면 409 `AD_BONUS_DAILY_LIMIT_REACHED`. `FREE_DAILY_LIMIT_REACHED` 문구에서 숫자 10을 뺐다. `api-contract/openapi.json`, 웹 생성 타입, 웹 `proAccessCopy.ts` 문구를 함께 갱신했다.
- **앱:** `core/ads/rewarded_ad_player.dart`(누를 때 불러와 바로 표시, 30초 제한, 표시 중 `FullScreenAdGuard` 기록), `widgets/ads/rewarded_ad_bonus_button.dart`(`광고 보고 5문제 더 풀기 · 오늘 n번 남음`), `pro_offer_sheet.dart`(시트 결과 반환), `pro_access_feedback.dart`·호출부 3곳·`random_practice_row.dart`(보너스를 받으면 막혔던 문제 이어 열기), `daily_set_bonus_card.dart`·`daily_set_result_page.dart`(결과 보너스 카드), 응답 모델·API·오류 코드.
- **검증:** 서버 보너스 판정 테스트 7개, 서버 전체 테스트, 계약 테스트 통과. 로컬 서버 + PostgreSQL 실측: 한도 10 > 광고 15 > 20 > 3번째 409, 세트 2/3 제출이면 완료 보너스 없음·3/3이면 +5, 정답률 +5, 최대 30, 동시 요청 3건 > 200·200·409. 앱 `flutter analyze` 문제 없음, 테스트 96개 통과. 시뮬레이터(운영 서버 + #809 개발자 도구 한도 흉내)에서 시트 광고 버튼 > 테스트 보상형 광고 > 이어 열기 > `15 / 15`·`오늘 1번 남음` > 다 쓰면 버튼 숨김을 확인했다.
- **리뷰 지적 2건 수정:** 시트를 그냥 닫아도 문제를 다시 요청해 시트가 반복되던 경로, 광고 시청 중 시트가 닫히면 보너스가 사라지던 경로.
- **광고 단위:** AdMob 보상형 광고 단위 Android `…/9971871042`, iOS `…/3658965325`. 키를 `app/.env`·`ENV_FILE`에 반영했다.

## 근본 원인 (확정)
버그가 아니라 정책 확장이다. 무료 한도가 고정 10이라 학습·광고 시청 보상 경로가 없었다.

## 재발 방지
- 무료 한도 판정은 계속 서버 `FeatureAccessPolicy` 한 곳이다. 앱의 남은 수·소진 판정은 `todayFreeLimit`을 쓰고, 혜택 문구는 `dailyFreeLimit`(기본 10)을 쓴다.
- 결제 스위치를 켤 때 최소 지원 버전을 이 기능이 들어간 버전으로 올려야 한다. 옛 앱은 `todayFreeLimit`을 몰라 10에서 막힌 것처럼 보인다([[ISS-0361-billing-switch-final-checks]], #596).

## 알고 남긴 것
- 광고 시청 확인은 앱 신고 방식이다. AdMob 서버 측 확인(SSV)은 하지 않았다. 조작해도 하루 +10문제가 상한이고, 남용이 보이면 SSV로 바꾼다.
- 오늘의 세트 결과 보너스 카드는 시뮬레이터에서 보지 못했다(운영 순위표에 테스트 계정이 올라가지 않게 세트를 풀지 않음).
- 남겨 둔 개선: 무료 회원이 문제를 열 때마다 보너스 조회 쿼리 4개가 더 돈다(기본 10 미만이면 생략 가능), `DailyFreeBonus.none()`의 최대 횟수 2, 광고 시청 뒤 보너스 요청 네트워크 실패 시 재시도 없음.

## 교훈
- 오늘의 세트 "완료 기록"은 제출 1건만 있어도 생긴다. 완료를 조건으로 보상을 주려면 배정 문제 수와 제출 수를 다시 비교한다.
