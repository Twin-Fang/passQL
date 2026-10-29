---
type: issue
id: ISS-0197
created: 2026-10-07
topics: [store-release]
symptoms: [App Store 심사 대기, WAITING_FOR_REVIEW, 심사 재제출, 빌드 교체, 승인 후 자동 출시]
root_cause: "해당 없음 — iOS 심사 진행 기록 이슈"
status: resolved
resolution: "[[ISS-0197-app-store-review-submission-report]]"
related: ["[[ISS-0192-play-closed-test-and-ios-review-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/352"
---

# ISS-0197: App Store 심사 제출

GitHub #352 (원본: 이슈 본문과 댓글).

## 증상
iOS 앱을 App Store에 출시하려면 심사 제출이 필요하다. 빌드, 메타데이터, 스크린샷, 개인정보 설문, 연령 등급, 가격·판매 지역이 흩어져 있어 한 곳에 기록한다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-06 16:49 UTC: 심사 제출 → `WAITING_FOR_REVIEW` (빌드 0.0.222). 스크린샷 iPhone 1206x2622 5장, iPad 13" 2064x2752 5장. 승인 후 자동 릴리스로 설정.
- 2026-10-08: 여전히 심사 대기. 같은 날 최신 빌드 **0.0.243**(87303614)으로 교체 재제출 — 0.0.222는 심사에서 제거(개발자 취소).
- 2026-10-10: 빌드 **0.7.0**(87397003)으로 다시 교체 재제출. 재제출이라 심사 대기 순번은 새로 시작한다고 적음.

## 근본 원인
해당 없음 (진행 기록 이슈). 심사가 왜 오래 대기했는지는 원본에 적혀 있지 않다.
