---
type: issue
id: ISS-0003
created: 2026-10-22
topics: [billing]
symptoms: ["수익 구조 없음", FeatureAccessPolicy, lockedSections, PRO_REQUIRED, FREE_DAILY_LIMIT_REACHED, pro_exam_pass, billing.android.enabled, "하루 10문제", "공정 사용 200"]
root_cause: "회원 등급·구독 상태를 담는 곳과 기능을 등급별로 막는 지점이 없었고, 제출 응답에 실행 결과·해설이 함께 실려 실행 API만 막으면 잠금이 샜다"
status: resolved
resolution: "[[ISS-0003-free-pro-plan-android-exam-pass-report]]"
related: ["[[DEC-0002-exam-pass-until-next-sqld]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0005-ship-with-billing-switch-off]]"]
source: "https://github.com/Twin-Fang/passQL/issues/576"
---

# ISS-0003: 무료, 프로 플랜과 Android 회차 패스 결제

GitHub #576 (원본: 이슈 본문과 `## 개요` 리포트 댓글).

## 증상
passQL은 SQLD 수험서를 대체하는 모바일 플랫폼이 목표지만 수익 구조가 없고 모든 기능이 무료였다. 회원 계정에 플랜·구독 상태를 담는 곳이 없고, 기능을 등급별로 막는 지점도 없었다. 앱에 결제 라이브러리가 없었다. 제출 응답(`POST /questions/{id}/submit`)에 실행 결과 표와 해설이 함께 실려 실행 API만 막아서는 잠금이 새어 나간다. 랜덤 풀기 API가 없었다.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-10-22: 무료/프로 경계 표, EarLocAlert(#294) 방식 잠금 시안 작성. 상품은 회차 패스, Android 먼저, 결제 스위치를 끈 채 배포로 정함.

## 근본 원인
등급 판정 단일 지점과 응답 단위 잠금(`lockedSections`)이 없던 구조.
