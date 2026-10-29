---
type: completion-report
id: ISS-0261
created: 2026-10-15
topics: [design-system]
status: resolved
resolves: "[[ISS-0261-app-theme-mode-setting]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/455"
---

# ISS-0261 완료 리포트: 설정에 화면 모드(시스템/라이트/다크), 기기 저장

GitHub #455 구현 보고서 댓글(2026-10-15) 기준. main `555a81a`(v0.9.0).

## 해결 방법
- `presentation/providers/theme_mode_provider.dart`(신규): `themeModeProvider`(`setMode`는 화면 먼저 반영 후 `SharedPreferences` 저장), `loadSavedThemeMode()`(값이 없거나 알 수 없으면 시스템), `initialThemeModeProvider`(main에서 `runApp` 전에 override → 첫 프레임부터 저장 모드).
- `main.dart`: `PassqlApp`을 `ConsumerWidget`으로, `themeMode: ref.watch(themeModeProvider)`. `widgets/settings/theme_mode_tile.dart`(신규), 설정 '학습' 그룹 아래 '화면' 그룹.
- 기기에만 저장 — 계정 설정이 아니라서 로그아웃·계정 변경에도 유지, `resetUserScopedProviders` 대상 아님.
- 공통 컴포넌트: `PqCheckRow`(신규, `Semantics(selected)`, 신고 사유 시트도 교체), `PqGroupedSection` `mainAxisSize.min`, `showPqSheet` `useRootNavigator: true`(닉네임 변경 시트도 영향).

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: `flutter test` 226개 통과(신규 2개), iOS 시뮬레이터 직접 조작, Android 에뮬레이터 통합본 실행.
- 주의(원본): `showPqSheet`가 최상위 Navigator를 써서 시트 안 `context.push`는 탭 밖에 쌓인다. `PqGroupedSection`을 `Expanded` 안에서 남은 높이를 채우게 의도한 곳은 재확인 필요(현재 없음). 저장 키 `theme_mode`, 값 `ThemeMode.name` — enum 이름이 바뀌면 시스템으로 돌아간다.

## 교훈
원본에 적혀 있지 않다.
