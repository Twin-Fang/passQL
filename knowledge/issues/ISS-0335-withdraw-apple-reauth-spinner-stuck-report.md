---
type: completion-report
id: ISS-0335
created: 2026-10-18
topics: [auth-member]
status: resolved
resolves: "[[ISS-0335-withdraw-apple-reauth-spinner-stuck]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/547"
---

# ISS-0335 완료 리포트: 잠금 창을 `navigator.pop()`으로 닫아 취소·실패 시 스피너 해제

GitHub #547 수정 완료 댓글 기준 (2026-10-18).

## 해결 방법
`_confirmWithdraw`에서 잠금 창을 `navigator.maybePop()` 대신 `navigator.pop()`으로 닫는다. `PopScope(canPop: false)`는 시스템 뒤로가기만 막고 코드의 `pop()`은 막지 않는다.

## 근본 원인 (확정)
`maybePop`이 `canPop: false`를 존중해 잠금 창을 닫지 않았다.

## 재발 방지
- `settings_error_handling_test.dart`에 취소·실패 테스트 2개 추가(수정 전 코드로 돌리면 실패, 수정 후 통과).
- 검증: `flutter analyze` 0, `flutter test` 526개, iOS 시뮬레이터(iPhone SE, 운영)에서 수정 후 스피너 해제·계정 유지.
- 운영에 탈퇴를 끝내지 못한 Apple 테스트 계정이 남아 있다(Apple 재인증 암호 필요로 사용자 확인). 앱은 스토어 미배포.

## 교훈
(원본에 없음, 볼트 정리) `PopScope(canPop: false)`로 막은 진행 창을 코드에서 닫을 때는 `maybePop`이 아니라 `pop`을 쓴다.
