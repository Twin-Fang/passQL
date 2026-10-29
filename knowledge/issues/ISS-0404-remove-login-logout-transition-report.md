---
type: completion-report
id: ISS-0404
created: 2026-10-26
topics: [auth-member, design-system]
status: resolved
resolves: "[[ISS-0404-remove-login-logout-transition]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/672"
---

# ISS-0404 완료 리포트: 로그인 라우트와 탭 쉘을 `NoTransitionPage`로

GitHub #672 리포트 댓글 기준.

## 해결 방법
`app/lib/router/app_router.dart`: 로그인 라우트와 탭 쉘(`StatefulShellRoute`)을 `builder`에서 `pageBuilder: NoTransitionPage`로 바꿨다. 하단 탭 4개는 이미 `NoTransitionPage`였다. 테마는 건드리지 않았다 — 테마를 바꾸면 푸시 화면의 밀기 전환과 뒤로 스와이프까지 사라지기 때문(리포트). `main_shots.dart`에 `/login-transition` 촬영 시나리오 추가.

## 근본 원인 (확정)
기본 `MaterialPage` + 테마의 Cupertino 밀기 전환.

## 재발 방지
- 탭 전환 페이드(`AppTabFadeStack`, GitHub #495)는 쉘 안쪽 동작이라 영향 없음.
- 약관, 점검, 강제 업데이트 화면은 기존 전환 그대로. 맞추려면 각 라우트에 `pageBuilder` 지정.
- 검증: `flutter analyze lib/router` 이슈 없음, `flutter test test/router test/architecture` 46개 통과. 실제 소셜 로그인·탈퇴 흐름, 안드로이드, 다크 모드는 확인하지 못함.

## 교훈
(원본에 없음, 볼트 정리) 상태 변화로 redirect되는 화면에 원치 않는 전환이 보이면 테마를 고치지 말고 해당 라우트의 page 종류부터 본다.
