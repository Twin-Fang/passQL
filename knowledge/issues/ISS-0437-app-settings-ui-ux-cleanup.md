---
type: issue
id: ISS-0437
created: 2026-11-01
topics: [design-system, notification]
symptoms: ["화면 모드 고르면 아래 묶음이 움직임", "기기의 라이트/다크 설정을 따라요", "자동일 때만 설명", "알림 묶음 아래 구분선 남음", "알림 종류 세 줄 사이 구분선 없음", "알림 받기를 켜면 고를 수 있어요 반복", PassqlGroupedSection, NotificationPreferenceTiles, "SizedBox.shrink 구분선", ThemeModeTile, "로그아웃 회원 탈퇴 묶음"]
root_cause: "화면 모드 보조 설명이 '자동'에서만 붙어 줄 높이가 바뀌었고, 알림 종류 세 줄이 묶음의 한 자식(Column, 못 읽으면 SizedBox.shrink)이라 묶음이 줄 사이 구분선을 못 그리고 빈 자식 앞에 선을 남겼다"
status: resolved
resolution: "[[ISS-0437-app-settings-ui-ux-cleanup-report]]"
related: ["[[ISS-0437-app-settings-ui-ux-cleanup-report]]", "[[DEC-0232-settings-theme-mode-device-label-no-subtitle]]", "[[DEC-0069-settings-tab-rows-only-subpages]]", "[[DEC-0071-settings-flat-grouped-list]]", "[[DEC-0171-four-tabs-merge-stats-my-profile]]", "[[ISS-0363-app-wide-ui-ux-cleanup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/774"
---

# ISS-0437: 앱 설정 화면 UI/UX 개선 (화면 모드 움직임, 알림 묶음 구분선, 계정 묶음)

GitHub #774 (원본: 이슈 본문과 구현 세션 대화).

> 상태: 리포트 댓글을 올렸고 PR #775가 main에 머지됐다 (2026-11-01). 완료 리포트: [[ISS-0437-app-settings-ui-ux-cleanup-report]]

## 증상
- 설정 > 화면 모드에서 '자동'일 때만 "기기의 라이트/다크 설정을 따라요" 한 줄이 붙어, 라이트·다크를 고르면 아래 묶음 전체가 한 줄만큼 올라갔다. 사용자: "UI적으로 움직임이 있어서 불편함".
- 알림 종류 설정을 못 불러오면 알림 묶음 맨 아래에 구분선이 남았다.
- 알림 종류 설정을 불러오면 학습 리마인더·복귀 알림·시험 D-day 세 줄 사이에 구분선이 없었다.
- 알림 받기가 꺼져 있으면 세 줄 설명이 모두 "알림 받기를 켜면 고를 수 있어요"로 같았다.
- 로그아웃과 회원 탈퇴가 서로 떨어진 두 묶음이었다.

## 재현 조건
- 설정 화면(내 프로필 > 톱니바퀴)에서 화면 모드 칸을 바꾼다.
- 시뮬레이터 캡처용 가짜 API(`tool/store_shots/main_shots.dart`)에는 원래 알림 종류 설정 응답이 없어 세 줄이 숨은 상태만 보였다. #774에서 응답을 추가했고 `/tmp/passql_shot_preferences.txt`에 `none`을 적으면 조회 실패 상황이 된다.

## 조사 기록
- 2026-11-01: 처음 찍은 '라이트' 캡처가 다크로 나왔다. 앱에 저장된 화면 모드('다크')가 시스템 모드를 덮었고, 앱 컨테이너의 `flutter.theme_mode`를 `system`으로 되돌린 뒤 다시 찍었다.
- 2026-11-01: `PassqlGroupedSection`은 자식 사이마다 구분선을 넣는다. `NotificationPreferenceTiles`가 세 줄을 `Column` 하나로 돌려주고, 설정을 못 읽으면 `SizedBox.shrink()`를 돌려주는 것을 코드로 확인했고, 가짜 응답을 넣은 캡처로 세 줄 사이 선이 없는 것을 확인했다.
- 2026-11-01: 이슈 본문에 "아이콘 타일 색에 기준이 없다"고 썼으나, `SettingsRow` 주석상 그 자리에서 바꾸는 줄은 보라, 이동·정보 줄은 회색이라는 기준이 있었다. 이슈 본문을 정정했다.

## 근본 원인
화면 모드 보조 설명이 '자동'일 때만 붙어 고를 때마다 줄 높이가 바뀌었다. 알림 종류 세 줄은 설정 묶음의 한 자식이라 묶음이 줄 사이 구분선을 그리지 못했고, 설정을 못 읽으면 빈 자식(`SizedBox.shrink()`) 앞에도 구분선이 붙었다.
