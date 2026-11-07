---
type: completion-report
id: ISS-0311
created: 2026-11-07
topics: [ads]
status: resolved
resolves: "[[ISS-0311-admob-ads-integration]]"
related: ["[[ISS-0320-ads-cards-notification-sheet-home]]", "[[ISS-0324-tab-bar-native-ad-strip]]", "[[DEC-0153-single-native-strip-under-tab-bar]]"]
source: "https://github.com/Twin-Fang/passQL/issues/506"
---

# ISS-0311 완료 리포트: AdMob 연동, 실제 광고 단위 10개, app-ads.txt, 방침 광고 고지, 스토어 출시까지

GitHub #506 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/506#issuecomment-6702514982) + 배포 후 실측 댓글(2026-11-07). 이슈 닫힘. 원본 사본: `_sources/issues/ISS-0311-admob-ads-integration-report.md`(로컬).

## 해결 방법
| 단계 | 내용 | 근거 |
|---|---|---|
| 앱 연동 | `lib/core/ads/` 모듈(자리와 단위 ID, SDK 지연 초기화, ATT, 배너, 네이티브, 전면 로더와 빈도 제한), 광고 배치 규칙 테스트 | PR #510 (`e996bdf7`), v1.7.0부터 |
| 실제 광고 단위 | AdMob 앱 2개, 광고 단위 10개, `ENV_FILE`에 키 12개 덧붙임 | 2026-10-17 후속 보고 |
| `app-ads.txt` | 웹 도메인 루트 게시 | PR #515, v1.13.0부터 |
| 개인정보처리방침 | 광고 식별자 처리, AdMob 제3자 제공, 맞춤형 광고 거부 항목, 소개 사이트 방침은 운영 API 본문에서 생성 | PR #514 (gh-pages) |
| 첫 출시 | iOS 1.13.0 심사 제출, Android 내부와 비공개 테스트 | 2026-10-17 |

배치는 이후 GitHub #522([[ISS-0320-ads-cards-notification-sheet-home]]), #527([[ISS-0324-tab-bar-native-ad-strip]], [[DEC-0153-single-native-strip-under-tab-bar]])로 바뀌었다.

## 검증
- 2026-10-17 운영 확인: 방침 7항, 소개 사이트 "맞춤형 광고 거부", `app-ads.txt` 200.
- 실제 노출: GitHub #783 조사(2026-11-02)에서 앱의 AdMob 앱 ID와 광고 단위 5종이 콘솔 값과 같고, 지난 7일 노출 Android 35회, iOS 100회.
- 판매 중인 iOS 1.77.1과 Android 프로덕션 1.83.0에 광고 포함.
- 배포 후 실측(2026-11-07, 1.88.0 main 빌드 시뮬레이터): 테스트 광고 기준 문제 탭 목록 사이 네이티브 광고와 맨 아래 배너.

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
- 디버그, 프로필 빌드는 항상 Google 테스트 단위(`AdUnitIds.shouldUseTestAds`). 실제 광고를 개발 중 누르면 계정 정지 위험이라 이 분기를 지우지 않는다.
- `ENV_FILE`은 여러 작업이 고치므로 기존 키를 보존해 덧붙인다.
- 방침은 관리자 화면에서 고친 뒤 `python3 -I _src/build_site.py`로 gh-pages 재생성. `privacy.html` 직접 수정 금지.
- `passql.vercel.app/app-ads.txt`를 지우면 iOS 광고가 제한된다.
- `google_mobile_ads` 버전을 올릴 때는 iOS 빌드부터 확인 (9.1.0은 `use_frameworks!` 빌드 실패).

## 남은 일
- AdMob 앱 인증(광고 게재 제한 해제)은 GitHub #783에서 이어서 다룬다. Android는 2026-11-02 스토어 연결, iOS는 App Store 마케팅 URL이 들어간 버전 판매 후 인증 재요청.

## 교훈
ATT는 앱 시작 직후에 묻는다. elum은 첫 광고 요청 때 물었다가 광고가 안 뜨는 경로로 쓴 심사관이 팝업을 보지 못해 App Review 2.1로 리젝됐다.
