---
type: issue
id: ISS-0485
created: 2026-11-07
topics: [billing, store-release]
symptoms: ["결제 시험 환경 세팅", "billing.play_service_account_json 비어 있음", "ads.reward.ssv_ad_unit_ids 비어 있음", "라이선스 테스터", "Sandbox 계정", "결제 미리보기 회원", billing.preview_member_uuids]
root_cause: ""
status: open
resolution: null
related: ["[[ISS-0361-billing-switch-final-checks]]", "[[ISS-0469-billing-switch-unverified-screens-races]]", "[[DEC-0005-ship-with-billing-switch-off]]"]
source: "_sources/issues/ISS-0485-billing-test-setup-e2e.md"
---

# ISS-0485: 결제 시험 환경 세팅과 결제 E2E (iOS·Android)

GitHub #941 (https://github.com/Twin-Fang/passQL/issues/941). 열린 시험 요청.

## 증상
결제를 켜기 전에 스토어·서버 세팅이 끝났는지 확인하고, 시험 결제 계정으로 결제 흐름 전체를 돌려야 한다. 전체 결제 스위치(`billing.android.enabled`)는 끄고 관리자 `billing.preview_member_uuids` 에 넣은 시험 계정만 결제 켜짐으로 시험한다.

## 재현 조건
해당 없음 (시험 요청).

## 조사 기록
- 2026-11-07: 운영 설정 읽기 전용 확인: 결제 스위치 false, 미리보기 회원 1명, `billing.play_service_account_json` 비어 있음(서버가 Play 구매를 확인할 수 없음), `ads.reward.ssv_ad_unit_ids` 비어 있음.
- 2026-11-07: Play Console 확인은 로그인된 브라우저를 다른 세션이 쓰고 있어 멈춤. App Store Connect 는 Apple 로그인·승인 필요.
- 시나리오(이슈 본문): 무료 잠금·한도 시트·광고 보너스, 1개월·3개월 구매 > 서버 확인 > 프로 반영, 구매 복원·다른 기기, 기간 만료, 환불, 실패 경로.

## 근본 원인
해당 없음 (시험 요청).
