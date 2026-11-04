---
type: completion-report
id: ISS-0442
created: 2026-11-04
topics: [ads]
status: resolved
resolves: "[[ISS-0442-app-open-ad-interstitial-cap-relax]]"
related: ["[[DEC-0238-app-open-ad-and-interstitial-cap-retune]]", "[[DEC-0148-inline-card-ads-interstitial-cap]]", "[[ISS-0443-free-daily-limit-bonus-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/787"
---

# ISS-0442 완료 리포트: 탭 복귀 앱 오프닝 광고 추가, 전면 광고 빈도 완화, 전체 화면 광고 겹침 방지

GitHub #787 리포트 댓글 기준 (2026-11-04). 원본 사본: `_sources/issues/ISS-0442-app-open-ad-interstitial-cap-relax-report.md` (로컬 전용).

> 머지 상태: 작성 시점(2026-11-04)에 미머지·미배포. 코드 커밋은 `c45fbe44`이고 브랜치는 푸시됐다. #808, #809 브랜치가 이 위에 쌓여 있어 이 노트도 그 코드 PR과 같이 들어간다.

## 해결 방법
- **앱 오프닝 광고(신규):** `app/lib/core/ads/app_open_ad_controller.dart`가 미리 불러오기, 복귀 판정, 표시를 맡는다. 불러 둔 광고는 3시간 55분 뒤 버린다(AdMob 앱 오프닝 광고 4시간 만료). 로더는 `app_open_ad_loader.dart`(30초 제한, 늦게 온 광고 해제, 클릭 기록).
- **제외 조건 4개:** 백그라운드 기록 없음(첫 실행), 30초 미만 복귀, 광고 때문에 나갔다 온 복귀, 다른 전체 화면 광고 표시 중.
- **빈도:** `app_open_frequency_cap.dart` — 1시간 간격, 하루 3회(기기 현지 날짜, 기기 단위 저장).
- **표시 위치:** `presentation/widgets/ads/app_open_ad_on_resume.dart`가 `AppLifecycleListener`로 백그라운드·복귀를 감지하고, 셸 라우트가 맨 위일 때만 시도한다(풀이·결과 화면 위에서는 안 뜸). `app_shell.dart`가 탭 셸을 감싼다.
- **배치·키:** `AdPlacement.appOpenResume`(env 접미사 `APP_OPEN`, 디버그는 Google 테스트 단위), 저장 키 3개(`storage_keys.dart`).
- **겹침 방지 공통 판정(신규):** `core/ads/full_screen_ad_guard.dart`가 전체 화면 광고 표시 중 여부와 마지막 광고 클릭 시각을 갖는다. 클릭 뒤 5초 안에 백그라운드로 가면 "광고 때문에 나감"으로 본다. `loaded_full_screen_ad.dart`는 전면·앱 오프닝이 함께 쓰는 "불러 둔 광고" 형태다. 배너·네이티브·전면 로더에 클릭 기록을 연결했다.
- **전면 광고 빈도 완화:** `interstitial_frequency_cap.dart` — 하루 3회 > 5회, 간격 5분 > 3분, 설치 후 건너뛰는 첫 결과 2회 > 1회.
- **복귀 판정 방식:** 나갈 때 기록하고 돌아올 때 한 번 판정한 뒤 기록을 지운다. 같은 복귀로 광고가 두 번 뜨지 않는다.
- **검증:** `flutter analyze` 문제 없음, 테스트 96개 통과(복귀 판정 4개: 첫 실행, 30초 경계, 광고 이탈, 1시간 간격). iOS 시뮬레이터에서 40초 뒤 복귀 시 테스트 앱 오프닝 광고가 뜨고 닫으면 탭 화면으로 돌아오는 것을 확인했다.
- **광고 단위:** AdMob 앱 오프닝 광고 단위 Android `…/8835270388`, iOS `…/2345883655`. 키 `PASSQL_ADMOB_{ANDROID|IOS}_APP_OPEN`을 `app/.env`와 CI 비밀값 `ENV_FILE`에 반영했다.

## 근본 원인 (확정)
버그가 아니라 정책 조정이다. 복귀 시 광고 자리가 없었고 전면 광고 빈도 제한이 수익 우선 방향에 비해 보수적이었다.

## 재발 방지
- 전체 화면 광고(전면·앱 오프닝·보상형)는 `FullScreenAdGuard` 한 곳에서 표시 중 여부를 판정한다. 새 전체 화면 광고도 이 판정을 거쳐야 겹치지 않는다(#808 보상형 광고가 재사용).
- 기준은 [[DEC-0238-app-open-ad-and-interstitial-cap-retune]]에 남겼다.

## 알고 남긴 것
- Android 실측을 하지 않았다. 전면 광고 Activity 복귀 경로는 코드 판정으로만 막았고, #809 테스트 빌드에서 확인해야 한다.
- 첫 실행(콜드 스타트) 광고는 일부러 넣지 않았다. 단가가 가장 높은 자리지만 스플래시 화면과 함께 설계해야 해서 범위에서 뺐다.
- 신규 설치 사용자 유예가 없다. 첫날에도 두 번째 복귀부터 앱 오프닝 광고가 뜰 수 있다. 이탈이 보이면 설치 후 유예를 추가한다.
- 빈도 기록은 기기 단위(SharedPreferences)라 계정을 바꿔도 이어진다.
- 남은 일: 실기기 확인(#809 테스트 빌드), 배포.

## 교훈
- Android에서 전면 광고를 닫고 돌아오는 것도 앱 생명주기상 "복귀"로 잡힌다. 복귀 광고를 넣을 때는 나가는 시점에 전체 화면 광고 표시 중인지를 먼저 기록한다.
