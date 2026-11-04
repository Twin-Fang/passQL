---
type: issue
id: ISS-0450
created: 2026-11-05
topics: [store-release, design-system]
symptoms: ["홍보 페이지 못생김", "github.io 밋밋", "옛 앱 아이콘", "Play 출시 준비 중 문구", "Google Play 준비 중 배지", "공유 이미지 옛 화면", "무료 Pro 비교표 결제 꺼짐", "옛 홈 캡처 D-day", gh-pages, site_content.py, IS_PLAY_STORE_PUBLIC, IS_PRO_PLAN_VISIBLE, feature-graphic.png]
root_cause: "앱 아이콘 교체(#766)·Play 공개·새 기능(개념 학습·결과 비교·매번 새 선택지)이 소개 사이트·README·Play 그래픽 이미지에 따라 들어가지 않았고, 사이트 아이콘·OG가 원본에서 생성되지 않는 사본이었다"
status: resolved
resolution: "[[ISS-0450-promo-site-dynamic-revamp-report]]"
related: ["[[ISS-0450-promo-site-dynamic-revamp-report]]", "[[DEC-0247-promo-site-free-banner-while-billing-off]]", "[[DEC-0248-site-icons-generated-from-brand]]", "[[DEC-0139-intro-site-generated-from-src]]", "[[ISS-0397-promo-site-overhaul-operator-notice]]"]
source: "https://github.com/Twin-Fang/passQL/issues/823"
---

# ISS-0450: 홍보 페이지(github.io) 다이나믹 개편, 새 아이콘·새 기능·Play 공개 반영

GitHub #823 이슈 본문 기준. 원본 사본: `_sources/issues/ISS-0450-promo-site-dynamic-revamp.md` (로컬 전용). 완료 리포트: [[ISS-0450-promo-site-dynamic-revamp-report]]

## 증상
- 사용자: "github.io 페이지 왤케 못생겼어, 다이나믹하게 홍보 제대로". 모바일 이미지 효과 요청. 검색 노출("sqld 공부앱" 상위)은 잘 돼 있으니 유지.
- 앱 아이콘을 시안 8번으로 바꿨는데(#766) 사이트 아이콘·파비콘·공유 이미지와 Play 그래픽 이미지는 옛 남색 아이콘 그대로.
- Google Play가 공개됐는데 사이트("Android 앱은 출시 준비 중")·FAQ·README 배지("준비 중")는 옛 상태.
- 홈 캡처에 지난 D-day(D-20), 공유 이미지에 "오늘의 3문제·SQLD 58회" 같은 옛 화면.
- 결제 스위치가 꺼져 모든 회원이 Pro로 판정되는데 사이트는 무료·Pro 비교표를 보여 줌.

## 재현 조건
twin-fang.github.io/passQL 첫 화면, README 배지, Play 그래픽 이미지 확인.

## 근본 원인
아이콘·Play 공개·새 기능 변경이 홍보 자산(소개 사이트, README, 스토어 그래픽)을 따라 갱신하는 절차에 묶여 있지 않았다. 사이트 아이콘·OG는 원본에서 생성되지 않는 손 사본이었다.
