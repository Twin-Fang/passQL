---
type: issue
id: ISS-0247
created: 2026-10-08
topics: [auth-member, store-release]
symptoms: [웹 회원 탈퇴 없음, "DELETE /api/members/me", 앱 출시 안내 배너, "store.android_url", "store.ios_url", 웹 앱 기능 동등성]
root_cause: "웹에 회원 탈퇴가 없고(앱에만 있음), 웹 이용자에게 앱 출시를 알릴 자리가 없었다"
status: resolved
resolution: "[[ISS-0247-web-withdrawal-app-release-banner-report]]"
related: ["[[DEC-0112-web-app-core-feature-parity]]"]
source: "https://github.com/Twin-Fang/passQL/issues/433"
---

# ISS-0247: 웹 회원 탈퇴 부재 + 앱 출시 안내 자리 없음 (웹·앱 핵심 기능 맞추기)

GitHub #433 (원본: 이슈 본문과 리포트 댓글).

## 증상
1. 웹에 회원 탈퇴가 없다 — 앱(설정 → 계정 → 회원 탈퇴)에만 있다. 약관·계정 삭제 안내 페이지도 웹 이용자에게 "앱이나 이메일로 탈퇴"라고 안내.
2. 웹에서 앱 출시를 알릴 자리가 없다 — 스토어 출시(Play 비공개 테스트 검토 중, iOS 심사 준비) 후 웹 이용자를 앱으로 안내해야 한다.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-10-08: 작업 계획 — 웹 설정 > 계정 관리에 회원 탈퇴, 서버 설정 키 `store.android_url`·`store.ios_url`(Flyway, 기본값 빈 문자열) + 공개 API `GET /api/meta/app-links`, 홈 배너·설정 "앱 다운로드", 안내 문구 정리, `docs/product/FEATURE-PARITY.md`.

## 근본 원인
웹·앱이 화면 단위로 따로 만들어져 핵심 기능(탈퇴)이 앱에만 있었다.
