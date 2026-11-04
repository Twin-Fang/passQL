---
type: issue
id: ISS-0443
created: 2026-11-04
topics: [billing, ads]
symptoms: ["무료 하루 한도", "랜덤 풀기 하루 10문제", "오늘 랜덤 10 / 10", "한도 보너스", "보상형 광고", "rewarded ad", "광고 보고 5문제 더 풀기", FREE_DAILY_LIMIT_REACHED, AD_BONUS_DAILY_LIMIT_REACHED, todayFreeLimit, dailyFreeLimit, dailyBonus, DailyFreeBonusRule, FeatureAccessPolicy, "plan/ad-bonus", member_daily_ad_bonus]
root_cause: "무료 랜덤 풀기 한도가 고정 10이라 오늘의 세트를 끝내거나 잘 푼 사람, 광고를 볼 사람에게 더 열어 줄 방법이 없었고 결제하지 않는 사용자에게서 수익이 나지 않았다"
status: resolved
resolution: "[[ISS-0443-free-daily-limit-bonus-report]]"
related: ["[[ISS-0443-free-daily-limit-bonus-report]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0178-daily-set-five-questions]]", "[[ISS-0361-billing-switch-final-checks]]", "[[ISS-0304-ads-rewarded-banner-pro-hide]]", "[[ISS-0442-app-open-ad-interstitial-cap-relax]]"]
source: "https://github.com/Twin-Fang/passQL/issues/808"
---

# ISS-0443: 무료 하루 한도 보너스 (오늘의 세트 완료·정답률·보상형 광고로 랜덤 문제 추가)

GitHub #808 (원본: 완료 리포트 댓글과 설계 문서 `docs/superpowers/specs/2026-11-04-free-daily-bonus-design.md`).

> 상태: 이 노트는 코드 PR과 같이 들어간다. 작성 시점(2026-11-04)에는 미머지·미배포다. 결제 스위치가 꺼져 있어 배포돼도 사용자에게는 보이지 않는다. 완료 리포트: [[ISS-0443-free-daily-limit-bonus-report]]

## 증상
- 기능 요청이다. 무료 회원의 랜덤 풀기는 하루 10문제 고정이었다([[DEC-0004-free-pro-feature-boundary]]).
- 공부를 한 사람(오늘의 세트 완료·정답률)에게 더 열어 주는 보상이 없었다.
- 결제하지 않는 사용자에게서 나오는 수익이 없었다. 보상형 광고는 #499에서 계획만 있었다.

## 재현 조건
결제 켜짐 무료 회원이 랜덤 풀기로 10문제를 풀면 `403 FREE_DAILY_LIMIT_REACHED`가 나고 이용권 시트만 열렸다.

## 조사 기록
- 2026-11-04: 서버는 오늘의 세트 문제 1개만 제출해도 완료 기록(`daily_set_submission`)을 만든다는 것을 확인했다. 완료 보너스는 "배정 문제 전부 제출"을 따로 확인하기로 했다.
- 2026-11-04: 랜덤 풀기 정답률은 쉬운 문제 재풀이로 올릴 수 있어 정답률 보너스는 오늘의 세트에만 걸기로 했다.

## 근본 원인
무료 한도가 고정 10이라 학습·광고 시청에 대한 보상 경로가 없었다. 버그가 아니라 무료 한도 정책 확장이다.
