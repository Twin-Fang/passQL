---
type: issue
id: ISS-0360
created: 2026-10-22
topics: [store-release]
symptoms: ["스토어 스크린샷", "옛 UI 캡처", "홍보 문구", "휴대폰 틀", store_shots, store_art, scenes.json, "스토어 설명 문구", "300문제 이상"]
root_cause: "Play Store·App Store 스크린샷이 문구·틀 없는 옛 UI 원본 캡처라 앱의 강점이 드러나지 않았다"
status: resolved
resolution: "[[ISS-0360-store-promo-images-descriptions-report]]"
related: ["[[DEC-0169-store-listing-korean-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/586"
---

# ISS-0360: 스토어 홍보 이미지·설명 문구 새로 만들기

GitHub #586 (원본: 이슈 본문과 댓글).

## 증상
기능 이슈. Play Store·App Store 스크린샷이 옛 UI 원본 캡처(문구·틀 없음)라 앱의 강점이 드러나지 않는다. 핵심 메시지: 책 없이 앱 하나로 SQLD, 최신 출제 경향, 300문제 이상, SQL 직접 실행, AI 해설.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-22 할 일: 스크린샷 도구(`app/tool/store_shots`) 보강, 다크 모드 원본 캡처 7장, 홍보 이미지 생성 도구 `app/tool/store_art`, iOS·Android 규격 이미지와 Play 그래픽 이미지, 설명 문구, Play·App Store 반영. 이슈 본문 체크리스트에서 App Store 반영 항목만 미체크로 남아 있으나 리포트 댓글은 App Store 1.37.0 심사 제출까지 적었다.
- 2026-10-23: 오늘의 세트가 실제 하루 10문제인데 도구 가짜 데이터가 3문제라 캡처·문구가 실제와 달랐음 → 정정(PR #590).

## 근본 원인
스토어 등록 이미지가 초기 원본 캡처 그대로였다.
