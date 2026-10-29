---
type: decision
id: DEC-0005
created: 2026-10-22
reviewed: null
topics: [billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0003-free-pro-plan-android-exam-pass]]"]
---

# DEC-0005: 결제 기능은 결제 스위치(`billing.android.enabled`)를 끈 채로 배포한다

## 문제 정의 (Context)
#576에서 결제·등급 판정을 처음 넣으면서 배포 방식을 정했다 (GitHub #576). 끈 채 배포하는 이유는 원본에 따로 적혀 있지 않고, 켜기 전 할 일(스토어 준비, iOS·웹 잠금, 최소 버전 상향)은 이후 #576·#578·#591 리포트에 쌓였다.

## 결정 (Decision)
스위치를 끈 채 배포한다. 꺼져 있으면 서버는 모든 판정을 허용하고 앱은 결제 UI를 그리지 않아 사용자에게 보이는 것은 기존과 같다. 스위치를 읽지 못하면 꺼짐으로 처리. 켜는 시점은 개념 학습 이후 결정(#576), 켜기 전 점검은 #596.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 결제 코드를 미리 병합·배포하면서 사용자 영향이 없다.

**부정**
- 스위치가 계정 기준 하나라 켜는 순간 Android·iOS·웹 모두에 잠금이 뜬다(#578) — 이름은 `android`지만 전 플랫폼 스위치 의미가 됐다(이름 변경은 #596로).
- 스위치가 꺼져 있으면 심사자가 구매 화면에 못 가 iOS 이용권 심사를 같이 낼 수 없다 — [[DEC-0007-hold-pass-review-until-switch-on]].

## 영향 범위 (Scope)
설정 `billing.android.enabled`(시드 false), `FeatureAccessPolicy`, 앱 설정 결제 플래그. 켜기 전 남은 일: 실구매 확인, 최소 버전 상향, Play 프로덕션 승인(#568), 이용권 심사(#596).

## 출처 (References)
- GitHub #576 이슈·리포트, #578 리포트, #591 리포트
