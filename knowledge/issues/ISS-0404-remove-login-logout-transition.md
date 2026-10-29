---
type: issue
id: ISS-0404
created: 2026-10-26
topics: [auth-member, design-system]
symptoms: ["로그인 후 홈 밀기 애니메이션", "로그아웃 후 로그인 화면 밀려 들어옴", MaterialPage, pageTransitionsTheme, app_router.dart, NoTransitionPage]
root_cause: "로그인 화면과 탭 쉘이 기본 MaterialPage로 열려, redirect로 화면이 바뀔 때 테마의 Cupertino 밀기 전환이 재생됐다"
status: resolved
resolution: "[[ISS-0404-remove-login-logout-transition-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/672"
---

# ISS-0404: 로그인·로그아웃 화면 전환 애니메이션 제거

GitHub #672 (원본: 이슈 본문과 댓글).

## 증상
하단 탭 전환에는 밀기 애니메이션이 없는데, 로그인 > 홈, 로그아웃·회원 탈퇴 > 로그인 화면 전환에는 오른쪽에서 밀려 들어오는 애니메이션이 나온다. 의도한 연출이 아니라 기본 동작이다(이슈 본문).

## 재현 조건
앱에서 로그인, 로그아웃, 회원 탈퇴, 세션 만료로 로그인 상태가 바뀔 때.

## 조사 기록
- 2026-10-26: 가짜 API로 로그인 상태만 바꾸는 촬영 시나리오 `/login-transition`으로 전후 녹화.

## 근본 원인
로그인 화면과 탭 쉘이 기본 `MaterialPage`로 열리고, `PassqlTheme`의 `pageTransitionsTheme`이 Cupertino 밀기 전환을 쓰므로 redirect가 화면을 맞바꿀 때 그 전환이 재생됐다(리포트).
