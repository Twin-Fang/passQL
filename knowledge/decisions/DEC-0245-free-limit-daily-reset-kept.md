---
type: decision
id: DEC-0245
created: 2026-11-04
reviewed: null
topics: [billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0448-mypage-account-pass-area-promo-code]]", "[[ISS-0448-mypage-account-pass-area-promo-code-report]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]"]
---

# DEC-0245: 무료 랜덤 풀기 한도 초기화는 하루 단위(KST 0시)를 유지하고 시간 충전은 하지 않는다

## 문제 정의 (Context)
마이페이지·결제 유도 설계(GitHub #816)에서 무료 한도를 시간 단위로 충전할지, 지금처럼 하루 단위로 초기화할지 정해야 했다. 지금 기준은 하루 10문제(KST, [[DEC-0004-free-pro-feature-boundary]]) + 보너스 3종(하루 기준 KST 0시, [[DEC-0239-free-daily-limit-bonus-three-kinds]]).

## 결정 (Decision)
- 무료 한도 초기화는 하루(KST 0시)를 유지한다. 시간 충전은 하지 않는다.
- 한도 소진 시 즉시 출구는 보상형 광고(+5)와 이용권이다.

## 검토한 대안 (Alternatives)
- **시간 충전:** "기다리면 됨"이 되어 결제 이유가 줄어든다는 이유로 버렸다 (이슈 본문 설계자 판단, 리포트 「핵심 구현」).
- **설치 후 3일 넉넉한 시작(하루 20문제, 결제 유도 ⑥):** 서버 한도 규칙 변경이라 별도 결정이 필요하다고 남겼다. 이 결정에 포함되지 않는다.

## 결과 (Consequences)
**긍정**
- 기다림이 결제 대안이 되지 않아 광고·이용권 출구가 유지된다.

**부정**
- 논의 기록 없음

## 영향 범위 (Scope)
서버 무료 한도 판정(`FeatureAccessPolicy` 등)과 보너스 하루 기준, 앱 "오늘 남은 문제" 표시("내일 0시에 다시" 문구). 지금 동작을 바꾸지 않는다.

## 출처 (References)
- GitHub #816 이슈 본문 「6. 무료 한도 초기화 기준」, 리포트 「핵심 구현」 (2026-11-04)
- 이슈: [[ISS-0448-mypage-account-pass-area-promo-code]], 리포트 [[ISS-0448-mypage-account-pass-area-promo-code-report]]
