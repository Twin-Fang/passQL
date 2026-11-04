---
type: issue
id: ISS-0442
created: 2026-11-04
topics: [ads]
symptoms: ["앱 오프닝 광고", "app open ad", "백그라운드 복귀 광고", "포그라운드 복귀", "전면 광고 빈도", "광고 겹침", "광고 수익", AppOpenAdController, AppOpenAdOnResume, FullScreenAdGuard, interstitial_frequency_cap, app_open_frequency_cap, AppLifecycleListener, PASSQL_ADMOB_ANDROID_APP_OPEN]
root_cause: "수익화를 늘리려는데 백그라운드에서 돌아올 때 광고 자리가 없었고, 결과 화면 전면 광고 빈도 제한(첫 결과 2회 건너뜀, 5분 간격, 하루 3회)이 보수적이었다"
status: resolved
resolution: "[[ISS-0442-app-open-ad-interstitial-cap-relax-report]]"
related: ["[[ISS-0442-app-open-ad-interstitial-cap-relax-report]]", "[[DEC-0238-app-open-ad-and-interstitial-cap-retune]]", "[[DEC-0148-inline-card-ads-interstitial-cap]]", "[[DEC-0153-single-native-strip-under-tab-bar]]", "[[ISS-0443-free-daily-limit-bonus]]", "[[ISS-0444-test-build-dev-tools-overlay]]"]
source: "https://github.com/Twin-Fang/passQL/issues/787"
---

# ISS-0442: 앱 오프닝 광고 추가와 결과 화면 전면 광고 빈도 완화

GitHub #787 (원본: 완료 리포트 댓글. 이슈 본문은 이 노트 작성에 쓰지 않았다).

> 상태: 이 노트는 코드 PR과 같이 들어간다. 작성 시점(2026-11-04)에는 미머지·미배포다. 완료 리포트: [[ISS-0442-app-open-ad-interstitial-cap-relax-report]]

## 증상
- 기능 요청이다. 사용자가 수익화를 위해 광고 노출을 늘리기로 했다("광고 늘어나도 상관없어", 수익 우선).
- 앱을 백그라운드에 뒀다가 탭 화면으로 돌아와도 광고가 없었다.
- 결과 화면 전면 광고는 설치 후 첫 결과 2회를 건너뛰고, 5분 간격, 하루 3회로 묶여 있었다([[DEC-0148-inline-card-ads-interstitial-cap]]).

## 재현 조건
앱 사용 중 다른 앱으로 30초 이상 나갔다 돌아오면 광고 없이 탭 화면이 보였다.

## 조사 기록
- 2026-11-04: Android 전면 광고는 별도 Activity라 앱이 잠깐 백그라운드로 가는 것처럼 보인다는 점을 확인했다. 그대로 두면 전면 광고를 닫고 돌아올 때 앱 오프닝 광고가 이어서 뜰 수 있어, 전체 화면 광고 판정을 공통 지점(`FullScreenAdGuard`)으로 모았다.

## 근본 원인
수익화 요구에 비해 복귀 시 광고 자리가 없었고 전면 광고 빈도 제한이 보수적이었다. 버그가 아니라 광고 정책 조정이다.
