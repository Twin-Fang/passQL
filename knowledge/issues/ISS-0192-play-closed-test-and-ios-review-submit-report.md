---
type: completion-report
id: ISS-0192
created: 2026-10-07
topics: [store-release, ci-deploy]
status: resolved
resolves: "[[ISS-0192-play-closed-test-and-ios-review-submit]]"
related: ["[[ISS-0197-app-store-review-submission]]", "[[ISS-0198-google-play-closed-testing]]"]
source: "https://github.com/Twin-Fang/passQL/issues/347"
---

# ISS-0192 완료 리포트: iOS 1.0 심사 대기, Play 비공개 테스트 0.0.220 게시

GitHub #347 댓글 기준 ("iOS 심사 제출 완료 (2026-10-07)", 진행 화면 캡처 댓글). `## 개요` 형식 리포트는 없음.

## 해결 방법
- iOS: App Store Connect 앱 6762165005, iOS 1.0(빌드 0.0.222 / 87235540) → "심사 대기 중". 연령 등급 4+, 가격 무료, 판매 지역 한국. "로그인 정보 필요" 체크를 해제하고 심사 메모에 Sign in with Apple/Google로 로그인한다고 안내.
- Android: 비공개 테스트 0.0.220 게시 (캡처 댓글 "Play 비공개 테스트 게시 완료", 검토 전송 변경사항 14개).

## 근본 원인 (확정)
해당 없음 (진행 관리 이슈).

## 재발 방지
후속: iOS 심사 결과 확인(GitHub #352), Play 비공개 테스트 검토 결과 확인 후 테스터에게 링크 공유(GitHub #353), 프로덕션 전 리뷰용 전용 테스트 계정 준비. 리뷰어가 로그인에 막히면 반려될 수 있다고 적혀 있다.

## 교훈
(원본에 없음, 볼트 정리) App Store 심사 제출에는 iPad 13" 스크린샷과 실제 심사 연락처 전화번호가 필요하다 — 마지막에 막힌 두 항목이다.
