---
type: completion-report
id: ISS-0437
created: 2026-11-01
topics: [design-system, notification]
status: resolved
resolves: "[[ISS-0437-app-settings-ui-ux-cleanup]]"
related: ["[[DEC-0232-settings-theme-mode-device-label-no-subtitle]]", "[[DEC-0069-settings-tab-rows-only-subpages]]", "[[DEC-0071-settings-flat-grouped-list]]"]
source: "https://github.com/Twin-Fang/passQL/issues/774#issuecomment-6551234349"
---

# ISS-0437 완료 리포트: 설정 화면 모드 높이 고정, 알림 묶음 구분선과 안내 정리, 계정 묶음 합침

GitHub #774 리포트 댓글 6551234349 기준 (2026-11-01).

> 머지 상태: PR #775가 main에 머지됐다 (2026-11-01). 코드 커밋은 `1020c68f`이다.

## 해결 방법
- **화면 모드:** 보조 설명을 빼고 시스템 모드 칸 이름을 `기기 설정`으로 바꿨다 (`theme_mode_tile.dart`, [[DEC-0232-settings-theme-mode-device-label-no-subtitle]]). 저장값(`ThemeMode.system`)은 그대로다.
- **알림 종류 줄:** 세 줄 묶음 위젯을 줄 하나짜리 `NotificationPreferenceTile` + 줄 목록 `notificationPreferenceRows` + 묶음 안내 `notificationPreferenceFooter`로 나눴다. 설정 화면은 설정을 읽었을 때만 세 줄을 묶음에 넣는다 (`settings_page.dart`).
- **안내 한 줄:** 알림 받기가 꺼져 있으면 세 줄은 원래 설명을 두고 흐리게(0.4) 하고, 묶음 아래에 "알림 받기를 켜면 고를 수 있어요" 한 줄. 켜져 있으면 같은 자리에 "공지는 이 설정과 상관없이 받아요" 한 줄을 둬 켜고 끌 때 높이가 같다. `SettingsGroup`이 `footer`를 넘기게 했다.
- **계정 묶음:** 로그아웃과 회원 탈퇴를 한 묶음에 넣고 탈퇴는 빨간색으로 맨 아래.
- **캡처용 가짜 API:** 알림 종류 설정 응답과 조회 실패 상황(`/tmp/passql_shot_preferences.txt` = `none`)을 추가했다.
- **그대로 둔 것 (사용자 확인):** 아이콘 색 기준(조작 줄 보라, 이동·정보 줄 회색), 한 줄짜리 학습·화면·토론 묶음, 실전 모드 설명(문제 탭과 같은 문구), 버전 줄 아이콘과 회원 ID 전체 표시(문의용).
- **검증:** `flutter analyze` 문제 없음, `flutter test test/architecture` 통과. 시뮬레이터 가짜 API로 라이트·다크, 설정 불러옴·못 불러옴 전후 캡처와 화면 모드 전환 영상을 비교했다.
- **확인하지 못한 것:** 알림 받기를 켠 상태(시뮬레이터에서 권한을 켤 수 없음).

## 근본 원인 (확정)
화면 모드 보조 설명이 '자동'일 때만 붙어 줄 높이가 바뀌었다. 알림 종류 세 줄이 설정 묶음의 한 자식(`Column`, 못 읽으면 `SizedBox.shrink()`)이라, `PassqlGroupedSection`이 자식 사이에 넣는 구분선이 세 줄 사이에는 없고 빈 자식 앞에는 남았다.

## 재발 방지
- 설정 묶음에 있을 수도 없을 수도 있는 줄은 위젯 안에서 `SizedBox.shrink()`로 숨기지 않고, 화면에서 넣을지 정한다.
- 여러 줄은 줄마다 묶음의 자식으로 넣어 구분선을 묶음이 그리게 한다.
- 상태에 따라 붙었다 사라지는 보조 설명·안내는 높이를 바꾼다. 늘 같은 줄 수를 두거나 빼서 높이를 고정한다.
- 알림 종류 줄은 열린 #653과 같은 영역이다. #653 작업은 줄 하나 단위로 바뀐 구조를 반영해야 한다.

## 교훈
- grouped 목록에서 구분선이 "남거나 빠지면" 먼저 묶음 자식이 몇 개인지(빈 자식, 여러 줄을 담은 한 자식)를 본다.
- 시뮬레이터 라이트·다크 캡처가 엉뚱한 모드로 나오면 앱에 저장된 화면 모드부터 확인한다.
