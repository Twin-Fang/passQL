---
type: decision
id: DEC-0247
created: 2026-11-05
reviewed: null
topics: [store-release, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0450-promo-site-dynamic-revamp]]", "[[ISS-0450-promo-site-dynamic-revamp-report]]", "[[DEC-0139-intro-site-generated-from-src]]"]
---

# DEC-0247: 결제 스위치가 꺼진 동안 소개 사이트는 무료·Pro 비교표 대신 "지금은 모든 기능이 무료" 안내를 보여 준다

## 문제 정의 (Context)
운영 결제 스위치(`app_settings billing.android.enabled`)가 꺼져 있으면 서버가 모든 회원을 Pro로 판정한다(`FeatureAccessPolicy`). 그런데 소개 사이트는 무료·Pro 비교표를 보여 줘 실제와 다른 안내가 됐다 (GitHub #823).

## 결정 (Decision)
- `_src/site_content.py`의 `IS_PRO_PLAN_VISIBLE`을 운영 결제 스위치와 맞춘다. 지금은 `False`.
- `False`이면 비교표 자리에 "지금은 모든 기능이 무료예요" 카드와 숫자 칸 "0원"을 보여 주고, FAQ도 "지금은 모든 기능이 열려 있어요"로 답한다.
- 결제를 켜는 날 `True`로 바꾸고 사이트를 다시 생성한다.

## 검토한 대안 (Alternatives)
- **비교표 유지:** 지금 살 수 없는 Pro를 안내하게 되어 버렸다.
- **요금 구역 통째로 숨김:** "모든 기능 무료"가 지금 가장 강한 홍보 문구라 안내로 바꿨다.

## 결과 (Consequences)
**긍정**
- 사이트 안내가 실제 앱 동작과 같다. 무료를 홍보 문구로 쓴다.

**부정**
- 결제 스위치와 손으로 맞추는 값이라, 결제를 켤 때 함께 바꾸지 않으면 사이트가 계속 "무료"로 남는다.

## 영향 범위 (Scope)
gh-pages `_src/site_content.py`(`IS_PRO_PLAN_VISIBLE`, `FREE_NOW_*`, `FREE_STAT_COUNTER`, FAQ), `_src/site_showcase.py`의 무료 안내·숫자 칸.

## 출처 (References)
- GitHub #823 리포트 「이렇게 한 이유」 (2026-11-05)
- 이슈: [[ISS-0450-promo-site-dynamic-revamp]]
