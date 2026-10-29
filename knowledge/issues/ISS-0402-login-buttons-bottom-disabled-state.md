---
type: issue
id: ISS-0402
created: 2026-10-26
topics: [auth-member, design-system]
symptoms: ["로그인 버튼 위치", "소셜 로그인 버튼 다시 눌림", "중복 로그인 요청", "로그인 중 버튼 반응 없음", login_page.dart, social_login_button.dart]
root_cause: "_signIn이 finally에서 항상 버튼을 다시 켜 성공 후 화면 전환 중에도 눌렸고, 잠긴 다른 버튼은 모양이 그대로였다"
status: resolved
resolution: "[[ISS-0402-login-buttons-bottom-disabled-state-report]]"
related: ["[[DEC-0180-social-login-disabled-opacity-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/668"
---

# ISS-0402: 로그인 화면 버튼 하단 배치와 로그인 중 버튼 비활성 표시

GitHub #668 (원본: 이슈 본문과 댓글).

## 증상
- 소셜 로그인 버튼 묶음이 세로 55% 지점에 있어 너무 위로 올라가 보인다.
- 로그인 성공 뒤 홈으로 넘어가는 짧은 순간에 버튼이 다시 눌리는 상태로 돌아온다(중복 로그인 요청 가능).
- 한 제공자로 로그인 중일 때 다른 버튼은 눌리지 않지만 모양이 그대로라 반응이 없는 것처럼 보인다.

## 재현 조건
앱 로그인 화면에서 소셜 버튼을 누르고 응답 대기 또는 성공 직후 화면 전환 구간.

## 조사 기록
- 2026-10-26: 수정 전후 캡처(iPhone 16 Pro 시뮬레이터, 라이트). 성공 후 잠금 유지는 위젯 테스트로 확인.

## 근본 원인
`login_page.dart`의 `_signIn`이 `finally`에서 항상 버튼을 다시 켰다. 배치는 로고·버튼 묶음을 한 덩어리로 55% 지점에 두는 Spacer(11:9) 때문.
