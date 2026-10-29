---
type: issue
id: ISS-0192
created: 2026-10-06
topics: [store-release, ci-deploy]
symptoms: [Play 비공개 테스트, App Store 심사 제출, TestFlight 업로드, 심사 연락처 전화번호, iPad 스크린샷, fastlane deploy 레인]
root_cause: "출시용 스토어 등록·서명·선언·테스터 설정이 흩어져 있었다 (진행 관리 이슈)"
status: resolved
resolution: "[[ISS-0192-play-closed-test-and-ios-review-submit-report]]"
related: ["[[ISS-0197-app-store-review-submission]]", "[[ISS-0198-google-play-closed-testing]]", "[[ISS-0191-store-public-legal-pages-metadata]]"]
source: "https://github.com/Twin-Fang/passQL/issues/347"
---

# ISS-0192: 스토어 출시 — Play 비공개 테스트 및 iOS 심사 제출

GitHub #347 (원본: 이슈 본문과 댓글).

## 증상
passQL 앱을 한국 대상으로 출시한다. Android는 Google Play 비공개 테스트까지, iOS는 App Store 심사 제출까지 해야 하는데 스토어 등록, 서명, 선언, 테스터 설정이 흩어져 있다.

## 재현 조건
해당 없음 (출시 진행 이슈).

## 조사 기록
- 2026-10-06: 완료 — Firebase 새 앱 ID(`com.coldredrice.passql`) 설정 교체·릴리스 SHA-1, Play 내부 테스트 0.0.220, iOS 수동 서명 프로파일 `passql-appstore-manual`·GitHub Secret 12개, iOS CI 수정 2건(아티팩트 복원 경로, fastlane `deploy` 레인), ASC 개인정보 URL·데이터 수집 설문.
- 2026-10-07: Play 앱 콘텐츠 선언 10개, 스토어 등록정보, 비공개 테스트(Alpha, 대한민국, "규랩스 테스터 목록" 44명) 검토 전송. iOS 빌드 0.0.222(87235540) TestFlight 업로드. 마지막 막힘은 심사 연락처 전화번호(임의 입력 불가)와 iPad 13" 스크린샷(iPad Pro 13 시뮬레이터 5장, 2064x2752).

## 근본 원인
해당 없음 (진행 관리 이슈).
