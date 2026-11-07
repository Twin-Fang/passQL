---
type: completion-report
id: ISS-0304
created: 2026-11-07
topics: [ads, billing]
status: resolved
resolves: "[[ISS-0304-ads-rewarded-banner-pro-hide]]"
related: ["[[DEC-0005-ship-with-billing-switch-off]]", "[[ISS-0443-free-daily-limit-bonus]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[ISS-0361-billing-switch-final-checks]]"]
source: "https://github.com/Twin-Fang/passQL/issues/499"
---

# ISS-0304 완료 리포트: Pro 광고 숨김(결제 켜짐 + 실제 프로만), 보상형 광고는 하루 한도 시트 +5문제와 서버 검증 콜백으로 다른 이슈에서 완료

GitHub #499 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/499#issuecomment-6702515127). 이슈 닫힘. 원본 사본: `_sources/issues/ISS-0304-ads-rewarded-banner-pro-hide-report.md`(로컬).

## 해결 방법
범위 정리 두 번: 2026-10-26 크레딧 명세 폐기로 이 이슈는 Pro 광고 숨김만, 2026-11-02 보상형 광고를 무료 하루 한도 안내 시트의 "광고 보고 문제 더 풀기"로 다시 정의(서버 검증 콜백, 하루 보상 한도).

| 항목 | 반영 내용 | 근거 |
|---|---|---|
| Pro 회원 광고 숨김 | 광고 허용 조건에 "Pro 아님", 등급을 모르면 광고 끔 | PR #664, v1.51.3부터 |
| 결제 꺼짐 보정 | 결제가 켜져 있으면서 실제 프로인 회원에게만 숨김 | PR #678, v1.54.1부터 |
| 보상형 광고 | 하루 한도 시트 "광고 보고 5문제 더"(하루 2회), 보상 뒤 서버 보너스와 막혔던 문제 이어 열기 | GitHub #808([[ISS-0443-free-daily-limit-bonus]]), 커밋 `8ec14dcd` |
| 서버 검증 콜백 | `GET /api/ads/admob/reward-callback` 서명 검증, 보상 표식과 거래 ID 중복 방지, 설정 `ads.reward.ssv_required`(기본 꺼짐) | GitHub #860, 커밋 `32745077`, `V1_77_2` |

## 검증
- Pro 숨김: 앱 테스트 689개, 판정 테스트 5가지, "결제 꺼짐과 PRO 응답" 판정 테스트.
- 스토어: Android 1.54.1 프로덕션, iOS 1.54.1 재제출(2026-10-27). 판매 중인 iOS 1.77.1과 Android 1.83.0에 포함.
- 서버 검증 콜백: #860 보고서 기준 AdMob 콘솔 Android, iOS 보상형 단위에 콜백 URL 등록, 둘 다 "콜백 URL이 확인되었습니다".

## 근본 원인 (확정)
이슈 노트 frontmatter `root_cause`와 같음. 결제 꺼짐에서 서버가 모두를 PRO로 내려주는 것은 [[DEC-0005-ship-with-billing-switch-off]] 운영 상태.

## 재발 방지
- 광고 숨김은 "결제 켜짐 + 실제 프로"로 판정한다. 등급 응답만 보면 결제 꺼짐 기간에 광고가 전부 사라진다.
- 전면 광고는 보여 주기 직전 조건을 다시 읽어, 구매 전 미리 불러둔 광고도 프로에게 나오지 않는다.

## 남은 일
- `ads.reward.ssv_required`는 아직 꺼짐. 보상 표식을 보내는 새 앱이 퍼진 뒤 관리자 설정에서 켠다(#860 운영 순서, 켜면 옛 앱은 광고 보너스를 못 받음).
- 보상형 광고 버튼은 결제가 꺼진 지금 사용자에게 안 보인다. 결제 스위치를 켤 때(GitHub #596, [[ISS-0361-billing-switch-final-checks]]) 캡처.

## 교훈
"프로면 끔" 같은 등급 조건은 결제 스위치가 꺼져 모두가 PRO로 보이는 기간의 동작까지 함께 판정한다.
