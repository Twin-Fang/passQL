---
type: decision
id: DEC-0282
created: 2026-11-12
reviewed: null
topics: [billing, ads, practice]
status: active
supersedes: DEC-0239
superseded_by: null
related: ["[[ISS-0488-free-practice-reward-flow]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[DEC-0245-free-limit-daily-reset-kept]]", "[[DEC-0004-free-pro-feature-boundary]]"]
---

# DEC-0282: 무료 랜덤 풀기 광고 보너스는 횟수 제한 없이 +5씩, 무료·프로 공통 하루 200문제 공정 사용 상한

## 문제 정의 (Context)
2026-11-11 결제 스위치를 켠 뒤 사용자가 무료 계정으로 직접 풀어 보며 보상 흐름을 다시 정했다 (GitHub #963). [[DEC-0239-free-daily-limit-bonus-three-kinds]]는 광고 보너스를 하루 2회, 무료 최대 30문제로 묶어 두었다.

## 결정 (Decision)
| 보너스 | 조건 | 추가 | 하루 |
|---|---|---|---|
| 기본 | — | 10 | — |
| 세트 완료 | 오늘의 세트 배정 문제 전부 제출 | +5 | 1회 |
| 세트 정답 | 오늘의 세트 맞힌 수 ≥ 배정 수의 80% | +5 | 1회 |
| 광고 | 보상형 광고(보상형 전면 광고 포함)를 끝까지 봄 | +5 | **횟수 제한 없음** |

- 무료 최대 30문제 상한을 없앤다.
- 화면에 드러내지 않는 공정 사용 상한을 무료·프로 공통 **하루 랜덤 제출 200문제**로 둔다(`FeatureAccessPolicy.DAILY_FAIR_USE_LIMIT`). 상한에 닿으면 `FAIR_USE_DAILY_LIMIT_REACHED`(429), 광고 보너스도 받지 않는다.
- 광고 인정은 AdMob 서버 검증 콜백으로만 한다(운영 `ads.reward.ssv_required=true`, 2026-11-12).
- 옛 앱(1.83.0~) 호환: 등급 응답 `dailyBonus.adBonusMaxCount`를 `받은 횟수 + 1`로 내려 옛 앱의 "광고 남은 횟수 있음"이 늘 참이 되게 한다. 새 앱은 이 값을 남은 횟수로 보여 주지 않는다. `AD_BONUS_DAILY_LIMIT_REACHED`는 더 내지 않지만 enum은 남긴다.
- 기본 10, 세트 보너스 수치, 하루 초기화(KST 0시, [[DEC-0245-free-limit-daily-reset-kept]])는 그대로 이어받는다.
- 사용자 지시: "세트완료, 세트정답 80%, 광고보기(무제한)으로 더줘, 이거 돈 아님?"

## 검토한 대안 (Alternatives)
- 광고 하루 2회 유지: 사용자가 광고는 볼수록 수익이라며 무제한을 골랐다.
- 상한 없이 완전 무제한: 자동화 남용을 막기 위해 설계자가 프로와 같은 200을 숨은 상한으로 넣었다(사용자 승인한 설계 문서에 명시).

## 결과 (Consequences)
**긍정**
- 결제하지 않는 회원도 광고로 계속 풀 수 있어 광고 수익이 늘 여지가 있다.
- 서버 검증 광고만 인정해 앱 조작으로 보너스를 받는 길이 막힌다.

**부정**
- 광고만 보면 계속 풀 수 있어 프로 구매 동기가 약해진다(사용자가 받아들임: 결제를 억지로 밀지 않음).
- `ads.reward.ssv_required`를 끄면 앱 신고만으로 하루 200문제까지 보너스가 쌓인다.
- 구글이 한 사람에게 광고를 너무 많이 보여 주면 채울 광고가 없어 실제로는 상한이 생긴다.

## 영향 범위 (Scope)
- 서버: `PQL-Application/.../entitlement/DailyFreeBonusRule.java`, `DailyFreeBonus.java`, `DailyAdBonusRecorder.java`, `AdBonusGrantService.java`, `FeatureAccessPolicy.java`, `MemberControllerDocs`, `AdRewardCallbackControllerDocs`, `api-contract/openapi.json`, 웹 생성 타입.
- 앱: `data/models/member/member_plan_response.dart`(`canEarnAdBonus`), `widgets/ads/rewarded_ad_bonus_button.dart`, `widgets/profile/profile_today_free_usage.dart`, `providers/dev_plan_overrides.dart`.

## 출처 (References)
- GitHub #963 완료 보고: https://github.com/Twin-Fang/passQL/issues/963#issuecomment-6803089405
- PR #964
