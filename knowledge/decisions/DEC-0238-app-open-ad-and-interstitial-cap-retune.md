---
type: decision
id: DEC-0238
created: 2026-11-04
reviewed: null
topics: [ads]
status: active
supersedes: DEC-0148
superseded_by: null
related: ["[[DEC-0148-inline-card-ads-interstitial-cap]]", "[[DEC-0153-single-native-strip-under-tab-bar]]", "[[ISS-0442-app-open-ad-interstitial-cap-relax]]", "[[ISS-0442-app-open-ad-interstitial-cap-relax-report]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]"]
---

# DEC-0238: 탭 복귀 시 앱 오프닝 광고를 넣고, 전면 광고는 첫 결과 1회만 건너뛰고 3분 간격·하루 5회로 늘린다 (인라인 카드 광고·탭 하단 띠는 유지)

## 문제 정의 (Context)
사용자가 수익화를 위해 광고 노출을 늘리기로 했다(GitHub #787). 사용자 지시는 "광고 늘어나도 상관없어"이고, 수익을 우선하되 사용성은 적당히 타협한다는 방향이다. 기존 [[DEC-0148-inline-card-ads-interstitial-cap]]은 전면 광고를 첫 결과 2회 건너뛰고 5분 간격·하루 3회로 묶었고, 백그라운드에서 돌아올 때의 광고 자리는 없었다.

## 결정 (Decision)
- **DEC-0148에서 유지:**
  - 상시 배너는 두지 않고, 홈 중간("학습 현황" 아래)과 통계 맨 아래에 카드 모양 광고(`AdInlineCard`)를 둔다. 광고가 없거나 실패하면 자리를 차지하지 않는다.
  - 네이티브 광고는 미디어 120x120 이상, 앱 카드와 같은 모양(앱이 직접 그리는 팩토리)이다.
  - 탭 셸 하단은 GitHub #527의 한 줄 네이티브 띠 하나를 쓴다([[DEC-0153-single-native-strip-under-tab-bar]]).
- **전면 광고(바뀜):** 설치 후 건너뛰는 첫 결과 2회 > 1회, 간격 5분 > 3분, 하루 3회 > 5회.
- **앱 오프닝 광고(신규):** 백그라운드에서 탭 화면으로 돌아올 때 띄운다.
  - 셸 라우트(탭 화면)가 맨 위일 때만 띄운다. 풀이·결과 화면 위에서는 뜨지 않는다.
  - 제외 조건 4개: 첫 실행(콜드 스타트), 30초 미만 백그라운드, 광고 클릭이나 전체 화면 광고 때문에 나갔다 온 복귀, 다른 전체 화면 광고 표시 중.
  - 빈도: 1시간 간격, 하루 3회(기기 단위).
- **겹침 방지:** 전체 화면 광고(전면·앱 오프닝, 이후 보상형)는 공통 판정 `FullScreenAdGuard` 하나로 표시 중 여부와 광고 클릭 이탈(클릭 뒤 5초 안 백그라운드)을 판정한다.

## 검토한 대안 (Alternatives)
- **첫 실행(콜드 스타트) 앱 오프닝 광고:** 단가가 가장 높은 자리지만 스플래시 화면과 함께 설계해야 해서 이번 범위에서 뺐다.
- **신규 설치 사용자 유예:** 넣지 않았다. 이탈이 보이면 설치 후 유예를 추가한다.
- 빈도 숫자(1시간·하루 3회, 3분·하루 5회)의 다른 값을 비교한 기록은 없다 (논의 기록 없음).

## 결과 (Consequences)
**긍정**
- 복귀 1회당 광고 자리가 생기고 전면 광고 노출이 늘어 광고 수익이 늘어날 것으로 본다. 실제 수익 변화는 아직 측정하지 않았다.
- 전체 화면 광고 판정이 한 곳에 모여 새 전체 화면 광고도 겹치지 않게 붙일 수 있다.

**부정**
- 광고가 늘어 사용성이 나빠질 수 있다. 신규 설치 사용자도 첫날 두 번째 복귀부터 앱 오프닝 광고를 볼 수 있다.
- 빈도 기록이 기기 단위라 계정을 바꿔도 이어진다.
- Android 전면 광고 Activity 복귀 경로는 작성 시점에 실기기로 확인하지 않았다.

## 영향 범위 (Scope)
- 앱 `app/lib/core/ads/`(`app_open_ad_controller.dart`, `app_open_ad_loader.dart`, `app_open_frequency_cap.dart`, `full_screen_ad_guard.dart`, `loaded_full_screen_ad.dart`, `interstitial_frequency_cap.dart`, `ad_placement.dart`), `presentation/widgets/ads/app_open_ad_on_resume.dart`, `presentation/widgets/app_shell.dart`, `core/storage/storage_keys.dart`.
- 설정: `app/.env`와 CI 비밀값 `ENV_FILE`의 `PASSQL_ADMOB_{ANDROID|IOS}_APP_OPEN`.
- DEC-0148의 인라인 카드·네이티브 팩토리(`AdInlineCard`, `passqlNativeCard`)는 그대로다.

## 출처 (References)
- GitHub #787 완료 리포트 댓글 (2026-11-04), 구현 세션의 사용자 지시
- 이슈: [[ISS-0442-app-open-ad-interstitial-cap-relax]], 리포트 [[ISS-0442-app-open-ad-interstitial-cap-relax-report]]
