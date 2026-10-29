---
type: issue
id: ISS-0335
created: 2026-10-18
topics: [auth-member]
symptoms: [회원 탈퇴 스피너 안 풀림, Apple 재인증 취소, ASAuthorizationError 1001, showPassqlBlockingProgress, "PopScope(canPop: false)", navigator.maybePop]
root_cause: "`_confirmWithdraw`가 `PopScope(canPop: false)` 잠금 창을 `navigator.maybePop()`으로 닫아 아무것도 닫히지 않았다"
status: resolved
resolution: "[[ISS-0335-withdraw-apple-reauth-spinner-stuck-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/547"
---

# ISS-0335: 회원 탈퇴 중 Apple 재인증 취소·실패 시 로딩 스피너가 해제되지 않음

GitHub #547 (원본: 이슈 본문과 댓글).

## 증상
설정 > 회원 탈퇴에서 Apple 재인증 시트를 닫거나(취소) 탈퇴가 실패하면 로딩 스피너가 영원히 남아 화면이 잠긴다. 앱을 다시 켜야 풀린다. 서버에는 탈퇴 요청이 가지 않는다.

## 재현 조건
iOS 시뮬레이터, 운영 서버. Apple 로그인 → 설정 > 회원 탈퇴 > "탈퇴하기" → "Apple로 로그인" 시트를 X로 닫기(`ASAuthorizationError 1001`) → 20초 이상 스피너 유지.

## 조사 기록
- 2026-10-18: 원인 확인·수정.

## 근본 원인
`settings_page.dart`의 `_confirmWithdraw`가 화면 잠금 창(`showPassqlBlockingProgress`, `PopScope(canPop: false)`)을 `navigator.maybePop()`으로 닫는다. `maybePop`은 `canPop: false`를 존중해 아무것도 닫지 않는다. 취소·실패 경로는 화면 전환이 없어 잠금 창이 남고, 성공 경로는 로그인 화면 전환에 가려져 드러나지 않았다.
