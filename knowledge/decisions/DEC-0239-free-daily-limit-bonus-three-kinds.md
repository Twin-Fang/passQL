---
type: decision
id: DEC-0239
created: 2026-11-04
reviewed: null
topics: [billing, ads]
status: superseded
supersedes: null
superseded_by: DEC-0282
related: ["[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0178-daily-set-five-questions]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[DEC-0238-app-open-ad-and-interstitial-cap-retune]]", "[[ISS-0443-free-daily-limit-bonus]]", "[[ISS-0443-free-daily-limit-bonus-report]]", "[[ISS-0361-billing-switch-final-checks]]"]
---

# DEC-0239: 무료 랜덤 풀기 하루 한도는 기본 10 + 보너스 3종(세트 완료 +5, 세트 정답률 80% +5, 보상형 광고 +5×2), 최대 30

## 문제 정의 (Context)
무료 랜덤 풀기는 하루 10문제 고정이었다([[DEC-0004-free-pro-feature-boundary]]의 "랜덤 풀기" 행). 사용자는 수익화를 원하고 광고가 늘어나는 것은 괜찮다고 했다. 공부를 한 사람과 광고를 본 사람에게 더 열어 주고, 결제하지 않는 사용자에게서도 보상형 광고 수익을 내려 했다 (GitHub #808).

## 결정 (Decision)
| 보너스 | 조건 | 추가 | 하루 |
|---|---|---|---|
| 기본 | — | 10 | — |
| 완료 | 오늘의 세트 완료 기록(KST 오늘)이 있고 오늘 배정 문제를 전부 오늘 제출함 | +5 | 1회 |
| 정답률 | 오늘의 세트 맞힌 수 ≥ 배정 수의 80% (`correctCount * 100 >= totalCount * 80`, 5문제면 4개, 배정 0개면 없음) | +5 | 1회 |
| 광고 | 보상형 광고 시청 완료 | +5 | 2회 |
| **무료 최대** | | **30** | |

- 정답률 보너스는 **오늘의 세트에만** 건다. 하루 한 번, 모두 같은 문제, 점수는 서버가 문제별 오늘 첫 제출로 계산하므로 반복 풀이로 쌓을 수 없다.
- 완료·정답률 보너스는 저장하지 않고 `daily_set_submission`과 오늘 배정 문제로 매번 계산한다. 광고 보너스만 `member_daily_ad_bonus`(회원·날짜·칸 unique)에 저장한다.
- 광고 시청 확인은 앱이 `onUserEarnedReward` 뒤에 `POST /api/members/me/plan/ad-bonus`를 부르는 **클라이언트 신고 방식**이다. AdMob 서버 측 확인(SSV)은 뒤로 미룬다. 조작해도 하루 +10문제가 상한이다.
- `MemberPlanResponse.dailyFreeLimit`은 기본 10 그대로 두고, 오늘 유효 한도는 새 필드 `todayFreeLimit`, 보너스 상태는 `dailyBonus`로 준다.
- 결제 스위치를 켤 때 최소 지원 버전을 이 기능이 들어간 버전으로 올린다(#596, [[ISS-0361-billing-switch-final-checks]]).
- 하루 기준은 KST 0시. 프로·결제 꺼짐 회원은 무제한이라 보너스가 없다.
- 사용자 지시: 보너스 종류는 "둘다", "정답률 좋으면 보상도 줘야지"로 세 가지 모두를 골랐고, 숫자는 "알아서해줘"로 설계자에게 맡겼다.
- [[DEC-0004-free-pro-feature-boundary]]를 대체하지 않는다. DEC-0004의 "랜덤 풀기 하루 10문제"를 기본값으로 두고 보너스로 구체화한다. 오늘의 세트 분량([[DEC-0178-daily-set-five-questions]])은 그대로다.

## 검토한 대안 (Alternatives)
- **시간마다 충전되는 방식(하트·에너지), 오답 감점:** 지금은 하지 않는다 (설계 문서 「하지 않는 것」).
- **랜덤 풀기 정답률 보상:** 쉬운 문제 재풀이로 조작할 수 있어 버렸다.
- **AdMob 서버 측 확인(SSV):** 공개 콜백 엔드포인트, 서명 검증, 콘솔 URL 설정이 필요하고 설정이 빠지면 보너스가 조용히 안 쌓인다. 남용 상한이 작아 후속으로 미뤘다.
- **보상형 광고 미리 불러오기:** 한도에 걸린 사람만 쓰므로 대부분 버려진다. 버튼을 누를 때 불러온다.
- **연속 학습 보너스:** 하지 않는다 (설계 문서 「하지 않는 것」, 이유 기록 없음).

## 결과 (Consequences)
**긍정**
- 오늘의 세트를 끝내고 잘 풀면 더 열려 매일 들어오는 습관을 강화한다.
- 결제하지 않는 사용자에게서도 보상형 광고 수익이 난다. 실제 수익은 결제 스위치를 켠 뒤에야 측정할 수 있다.

**부정**
- 앱 신고 방식이라 광고를 보지 않고 보너스를 받을 수 있다(하루 +10 상한).
- 옛 앱은 `todayFreeLimit`을 몰라 10에서 막힌 것처럼 보인다. 최소 버전 상향이 결제 켜기 선행 조건이 된다.
- 무료 회원이 문제를 열 때마다 보너스 조회 쿼리 4개가 더 돈다.

## 영향 범위 (Scope)
- 서버: `PQL-Application/.../entitlement/`(`DailyFreeBonusRule`, `DailyFreeBonusReader`, `DailyFreeBonus`, `DailyFreeBonusInput`, `FeatureAccessPolicy`), `MemberPlanResponse`, `PQL-Domain-Member`의 `MemberDailyAdBonus`, Flyway `V1_72_2__member_daily_ad_bonus.sql`, `MemberController`, `ErrorCode`(`AD_BONUS_DAILY_LIMIT_REACHED`).
- 계약: `api-contract/openapi.json`, 웹 `client/src/types/generated/openapi.ts`, `proAccessCopy.ts`.
- 앱: `core/ads/rewarded_ad_player.dart`, `widgets/ads/rewarded_ad_bonus_button.dart`, `widgets/pro/pro_offer_sheet.dart`, `pro_access_feedback.dart`, `random_practice_row.dart`, `widgets/daily_set/daily_set_bonus_card.dart`, `daily_set_result_page.dart`, `plan_providers.dart`, `member_api.dart`, `error_code.dart`.
- 설정: `PASSQL_ADMOB_{ANDROID|IOS}_REWARDED_DAILY_BONUS`.

## 출처 (References)
- GitHub #808 완료 리포트 댓글 (2026-11-04), 설계 문서 `docs/superpowers/specs/2026-11-04-free-daily-bonus-design.md`(로컬 전용), 구현 세션의 사용자 지시
- 이슈: [[ISS-0443-free-daily-limit-bonus]], 리포트 [[ISS-0443-free-daily-limit-bonus-report]]
