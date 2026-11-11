---
type: decision
id: DEC-0285
created: 2026-11-12
reviewed: null
topics: [ads, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0488-free-practice-reward-flow]]", "[[DEC-0238-app-open-ad-and-interstitial-cap-retune]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]"]
---

# DEC-0285: 결과 화면의 일반 전면 광고를 보상형 전면 광고(+5)로 바꾼다 — 토픽 결과는 들어올 때, 오늘의 세트 결과는 떠날 때

## 문제 정의 (Context)
사용자가 AdMob 콘솔의 "보상형 광고 전략 최적화(보상형 전면 광고)" 카드를 보여 주며 "그래야지, 그렇게 전체적으로 다 수정해줘야지"라고 했다 (GitHub #963). 결과 화면의 일반 전면 광고는 보상 없이 흐름을 끊었다.

## 결정 (Decision)
- 토픽 챕터 결과(들어올 때)와 오늘의 세트 결과(떠날 때)의 일반 전면 광고(`interstitial_result`)를 보상형 전면 광고(`rewarded_interstitial_result`)로 바꾼다. 끝까지 보면 광고 보너스 +5([[DEC-0282-ad-bonus-unlimited-fair-use-200]], 서버 검증).
- 정책상 광고 전에 "광고를 보면 5문제가 더 열려요", 5초 카운트다운, "건너뛰기"를 보여 준다. 광고를 먼저 불러 둔 경우에만(5초 제한) 안내를 띄운다.
- 오늘의 세트 결과는 들어올 때 보상 연출이 있어 떠날 때 띄운다. 랜덤 요약에는 광고가 없다. 세트 결과의 "랜덤 풀기로 이어 가기"는 광고 없이 떠난다(공부하러 가는 사람에게 광고를 끼우지 않음).
- 유료 프로·결제 꺼짐에는 띄우지 않는다.
- 빈도 제한은 기존 결과 화면 전면 광고 규칙과 기록 키를 그대로 이어 쓴다(안내를 띄운 때를 1회로 셈).
- AdMob 단위: Android `…/4774843089`, iOS `…/5513209685`, 서버 측 확인 콜백 등록, 운영 `ads.reward.ssv_ad_unit_ids`에 추가.

## 검토한 대안 (Alternatives)
- 일반 전면 광고 유지: 보상 없이 흐름만 끊어 버렸다.
- 오늘의 세트 결과도 들어올 때: 보상 연출과 겹쳐 버렸다.

## 결과 (Consequences)
**긍정**
- 같은 광고 노출에 보상이 붙어 "억지로 보는 광고"가 "보상 받는 광고"가 된다.

**부정**
- 새 광고 단위라 초기 채움률이 낮을 수 있고, 미리 불러오기로 노출률(불러온 수 대비 노출)이 내려갈 수 있다.
- 쓰지 않게 된 일반 전면 광고 파일 4개가 남아 있다(삭제 허락 대기).

## 영향 범위 (Scope)
- 앱: `core/ads/ad_placement.dart`, `rewarded_interstitial_ad_player.dart`, `rewarded_ad_player.dart`(보상형 형식 공통 표시), `full_screen_ad_loading.dart`, `interstitial_frequency_cap.dart`, `widgets/ads/rewarded_interstitial_*`, `ad_bonus_claim.dart`, `pages/questions/chapter_result_page.dart`, `pages/daily_set/daily_set_result_page.dart`, `design/components/passql_dialog.dart`(`closePassqlDialogRoute`).
- 운영: AdMob 콘솔, 앱 `.env` 키 `PASSQL_ADMOB_{ANDROID|IOS}_REWARDED_INTERSTITIAL_RESULT`, GitHub Secret `ENV_FILE`.

## 출처 (References)
- GitHub #963 완료 보고: https://github.com/Twin-Fang/passQL/issues/963#issuecomment-6803089405
