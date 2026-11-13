---
type: doc
id: DOC-0005
doc_type: design
authority: internal
created: 2026-11-13
reviewed: null
source: "https://github.com/Twin-Fang/passQL/tree/118159a8"
topics: [ads]
topics_ref: [billing, practice]
decisions: []
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0238-app-open-ad-and-interstitial-cap-retune]]", "[[DEC-0273-maintenance-mode-passes-external-callbacks]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]", "[[DEC-0283-daily-limit-view-reward-first]]", "[[DEC-0285-result-rewarded-interstitial]]", "[[DOC-0003-practice-implementation-code-trace]]"]
---

# DOC-0005: 광고 보상(광고 보너스) 검증 구현 코드 추적 — 앱·서버

## 요약
2026-11-13 main(`118159a8`, v1.120.0) 코드를 직접 따라가 정리한 광고 보상 지도다. 무료 회원이 보상형(또는 보상형 전면) 광고를 끝까지 보면 하루 한도에 +5 크레딧이 붙는다. 기록 경로는 둘이다. (1) 앱 신고 `POST /api/members/me/plan/ad-bonus`, (2) AdMob 서버 검증 콜백(SSV) `GET /api/ads/admob/reward-callback`. 두 경로는 앱이 광고마다 만든 보상 표식(`rewardNonce` = SSV `custom_data`)과 AdMob 거래 ID로 같은 광고를 한 번만 기록한다. 앱 신고만으로 기록할지는 설정 `ads.reward.ssv_required`가 정한다. 코드가 바뀌면 이 문서는 낡으므로, 인용 전에 파일이 아직 있는지 확인한다.

## 핵심 내용 · 논점

### 스택별 역할
| 스택 | 역할 | 주요 위치 |
|---|---|---|
| 앱 | 광고 자리별 단위 해석, 보상형 재생, 서버 검증 값 설정, 보너스 확인 | `app/lib/core/ads/`(`ad_placement`, `rewarded_ad_player`, `rewarded_interstitial_ad_player`, `ad_request_preparer`, `full_screen_ad_guard`, `interstitial_frequency_cap`, `app_open_frequency_cap`), `presentation/widgets/ads/ad_bonus_claim.dart`, `presentation/providers/plan_providers.dart` |
| 서버 | 콜백 서명 확인, 보너스 기록, 한도 계산 | `PQL-Web/.../AdRewardCallbackController`, `MemberController`(`/me/plan/ad-bonus`), `PQL-Application/.../ads/`(`AdMobRewardCallbackVerifier`, `GstaticAdMobVerifierKeyClient`), `.../entitlement/`(`AdBonusGrantService`, `DailyAdBonusRecorder`, `DailyFreeBonusRule`) |

### 앱: 광고 자리와 단위
- `AdPlacement` 8종: `nativeStrip`, `bannerHome`, `bannerStats`, `nativeQuestions`, `interstitialResult`, `appOpenResume`, `rewardedDailyBonus`, `rewardedInterstitialResult`. `.env` 키 `PASSQL_ADMOB_{ANDROID|IOS}_{자리}`.
- 디버그·프로필·개발용(테스트 배포) 빌드는 항상 Google 공식 테스트 단위를 쓴다. 운영 빌드만 `.env`의 실제 단위, 비면 광고 없음.

### 앱: 보상 흐름 (`ad_bonus_claim.dart`)
1. 진입 2곳: 한도 화면 광고 버튼(보상형), 결과 화면 보상형 전면 광고(미리 불러 둔 경우에만 안내).
2. 보상 표식 만들기(UUID) > 광고 로드(보상형 30초, 보상형 전면 5초 제한) > 서버 검증 값 설정(`user_id` = 회원 UUID, `custom_data` = 표식, 실패해도 광고는 보임) > 표시 > 닫힘까지 대기 > 보상 여부.
3. 보상이면 `grantAdBonus`(표식 포함). 같은 표식이라 여러 번 불러도 1회만 기록된다.
4. 409 `AD_BONUS_VERIFICATION_PENDING`이면 2초 간격 최대 5번 다시 확인, 끝내 대기면 등급을 새로 받고 안내. 일시 실패는 1회 재시도. 공정 사용 상한, 426 `AD_BONUS_APP_UPDATE_REQUIRED` 등은 바로 실패.
5. 표시 중에는 전체 화면 광고 표시 중으로 기록해 앱 오프닝·전면 광고와 겹치지 않게 한다.

### 서버: 앱 신고 `AdBonusGrantService.grantByAppReport`
1. 프로(결제 꺼짐 포함) > 기록 없이 현재 등급.
2. 표식 형식 확인(`[0-9A-Za-z-]{1,64}`, 아니면 null 취급). 이미 기록된 표식 > 현재 등급.
3. 오늘 랜덤 제출 수가 공정 사용 상한(200) 이상 > 429 `FAIR_USE_DAILY_LIMIT_REACHED`.
4. `ads.reward.ssv_required` 켜짐 > 기록하지 않고 거절: 표식 없는 옛 앱은 426 `AD_BONUS_APP_UPDATE_REQUIRED`, 그 외는 409 `AD_BONUS_VERIFICATION_PENDING`(콜백이 먼저 기록했다면 2단계에서 이미 통과).
5. 꺼짐 > `saveAdBonusWithRetry`(동시 저장 충돌 2회면 이미 반영된 것으로 봄) > 현재 등급.

### 서버: SSV 콜백 `grantByServerVerification`
1. `AdMobRewardCallbackVerifier.verify(원본 쿼리)`: 쿼리 `&signature=` 앞이 서명 대상, 뒤는 `signature`·`key_id` 두 개만 허용 > `key_id`로 공개키 > `SHA256withECDSA` 검증. 실패만 403 `ACCESS_DENIED`.
2. 공개키는 `GstaticAdMobVerifierKeyClient`가 `https://www.gstatic.com/admob/reward/verifier-keys.json`을 24시간 캐시, 모르는 `key_id`면 다시 받기(1분 간격 제한), 받기 실패면 이전 목록 유지, 목록이 비면 `EXTERNAL_API_ERROR`(AdMob 재전송 유도).
3. 허용 광고 단위(`ads.reward.ssv_ad_unit_ids`, 비었거나 읽기 실패면 확인 안 함) > 회원 UUID·거래 ID(128자 이하) 확인 > 프로·같은 거래 ID·같은 표식·공정 사용 상한이면 건너뜀(200) > `saveAdBonusWithRetry(회원, 표식, 거래 ID)`.
4. 점검 모드에서도 이 콜백 경로는 통과한다(DEC-0273, `ExternalCallbackPaths`).

### 한도 반영
- 기록은 `member_daily_ad_bonus`(칸 번호 `DailyFreeBonusRule.nextAdBonusSlot`, 끝 없음). 오늘 광고 보너스 횟수 x 5가 무료 한도에 더해진다. 판정은 [[DOC-0003-practice-implementation-code-trace]]의 하루 한도 판정.
- 옛 앱 호환 `adBonusMaxCount = 받은 횟수 + 1`(항상 더 받을 수 있음).

## 추출된 결정
없음. 이미 구현된 내용을 지도로 옮긴 문서라 새 결정은 만들지 않았다. 관련 결정은 `related`에 연결했다.

W4 대조(구현 vs 활성 결정): DEC-0273(점검 모드 콜백 통과), DEC-0282(광고 보너스 횟수 제한 없음, 공정 사용 200, 옛 앱 `adBonusMaxCount`), DEC-0285(결과 화면 보상형 전면 +5)와 코드가 일치했다. 충돌 없음. 결정 본문은 읽지 않고 클러스터 한 줄 요약과 대조했다. 전면·앱 오프닝 빈도(DEC-0238)는 빈도 제한 코드를 열어 보지 않아 대조하지 않았다.

## 열린 질문
- **SSV 기본값 꺼짐**: `IS_SSV_REQUIRED_BY_DEFAULT = false`라 설정 행이 없거나 저장소 장애면 앱 신고만으로 기록된다(출시 앱 호환 목적, 코드 주석). 운영 설정값은 이번에 확인하지 않았다.
- **광고 단위 확인 생략**: 허용 단위 목록이 비면 어떤 단위의 콜백도 받는다.
- **표식 없는 콜백**: `custom_data`가 없거나 형식 밖이면 표식 없이 거래 ID만으로 기록한다. 이때 앱 신고와 같은 광고로 묶이지 않는다.

## 원본 참조
- 코드 기준: main `118159a8` (2026-11-13, v1.120.0). 원문은 코드 자체이며 별도 텍스트 원본은 없다.
