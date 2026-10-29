---
type: completion-report
id: ISS-0360
created: 2026-10-23
topics: [store-release]
status: resolved
resolves: "[[ISS-0360-store-promo-images-descriptions]]"
related: ["[[DEC-0169-store-listing-korean-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/586"
---

# ISS-0360 완료 리포트: 홍보 이미지 7장·설명 문구를 도구로 생성해 두 스토어에 제출

GitHub #586 리포트 댓글(`## 개요`, 2026-10-23)과 후속 댓글(PR #590) 기준.

## 해결 방법
- 홍보 이미지 생성 도구 `app/tool/store_art/`: `scenes.json`(장면 7개·규격 4종, 문구는 이 파일만 고침), `render.py`(Chrome 헤드리스 정확한 픽셀 캡처, 크기 검증, 알파 제거). 재생성 `python3 -I app/tool/store_art/render.py`.
- 결과물 `app/docs/store/`: `promo/ios-6.3/`(1206x2622, App Store 필수 칸), `promo/ios-6.9/`·`promo/ios-6.5/`(예비), `promo/android-phone/`(1080x1920), `promo/feature-graphic.png`(1024x500), `promo/source/`(원본 캡처 7장), `descriptions/`.
- 장면 제목 7개: 책 없이, 앱 하나로 SQLD / 요즘 시험에 나오는 유형 그대로 / 300문제 이상, 주제별로 차근차근 / 보기 SQL을 직접 실행해 봐요 / 틀린 이유, AI가 바로 짚어 줘요 / 내 실력, 숫자로 확인해요 / 매일 같은 문제로 함께 겨뤄요.
- 스크린샷 도구 `main_shots.dart`: 광고 끔(`adsEnabledProvider` false), 시험 회차 58회 > 63회(2026-11-14), 연출 `execute-ok`.
- 스토어 반영: Play 등록정보 교체 후 검토 제출(AI 애셋 선언 "라벨 지정 안 함" — 실제 캡처 + HTML 합성). iOS 1.37.0 빌드(88645758) 심사 제출. App Store 심사 메모의 "광고, 추적, 결제 기능은 없습니다"를 AdMob 광고·ATT 요청·iOS 결제 없음으로 고쳐 제출.
- 후속(PR #590): 오늘의 세트 10문제로 도구 데이터·캡처·문구 정정, Play 재검토 제출, App Store 1.37.0 심사 취소 후 교체 재제출. README 첫 화면 개편.

## 근본 원인 (확정)
원본에 별도 원인 서술 없음(이슈 본문의 "옛 UI 원본 캡처"가 출발점).

## 재발 방지
- 주의: 로컬 Xcode 16.2에서 `in_app_purchase_storekit 0.4.13`이 컴파일되지 않아(`Product.PurchaseOption has no member introductoryOfferEligibility`) 캡처용 빌드만 `pubspec_overrides.yaml`로 0.4.8+1 임시 고정 후 원복(CI 영향 없음, 근본 해결은 Xcode 업데이트). Play 애셋 보관함에서 여러 장을 한꺼번에 넣으면 순서가 섞인다. "300문제 이상"은 10-20 기준 활성 309개 근거 — 문제 수가 줄면 문구도 고친다. 결제 스위치를 켤 때 설명 문구에 무료·프로 구분. App Store는 문구를 바꾸면 새 버전 심사 필요.
- 전체 테스트(PR #590): 앱 673 통과, 서버 `ChoiceSetEntityIntegrationTest` 1건 실패(로컬 FK, 기존 문제), 웹 `designTokens.test.ts` 1건 실패 — GitHub #574의 앱 글자색 대비 보정(text-secondary #636366, success-text #1A6E30, error-text #C40012)이 웹 토큰에 미반영(별도 처리 필요).

## 교훈
(원본에 없음, 볼트 정리) 스토어 캡처용 가짜 데이터는 실제 운영 값(문제 수 등)과 맞는지 문구와 함께 대조한다.
