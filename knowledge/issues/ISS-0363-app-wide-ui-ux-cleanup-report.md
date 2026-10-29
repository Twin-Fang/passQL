---
type: completion-report
id: ISS-0363
created: 2026-10-24
topics: [design-system, home, practice]
status: resolved
resolves: "[[ISS-0363-app-wide-ui-ux-cleanup]]"
related: ["[[DEC-0171-four-tabs-merge-stats-my-profile]]", "[[DEC-0172-flexible-layout-no-fixed-sizes]]", "[[DEC-0173-no-new-tests-in-repo]]"]
source: "https://github.com/Twin-Fang/passQL/issues/602"
---

# ISS-0363 완료 리포트: 공통 지점 수정, 탭 4개(내 프로필 통합), 폭·글자 배율 조합에서 넘침 없음

GitHub #602 리포트 댓글(`## 개요`, 2026-10-24)과 진행·배포 댓글 기준. PR #603, #604(GitHub #601), #605. 구현 커밋 `13db4b1d`, `4791f56f`, `a3e169ac`, `87cf66c0`, `dfed371e`, 후속 `3eb5d183`.

## 해결 방법
- 공통 컴포넌트: `passql_sheet.dart`(X·`hasCloseButton` 제거, 제목 가운데), `report_button.dart`(문제 신고 아이콘만, `Tooltip`+`PassqlSemanticButton`), `community_opinion_chip.dart`·`chapter_feedback_bar.dart`(`isCompact`), `passql_code_block.dart`·`choice_item_card.dart`(코드 배경 제거 `hasBackground`). AI 해설 미리보기 근거 2줄 → 1줄.
- 홈: `daily_set_card.dart`(버튼 `풀어보기` 하나 + 머리 `순위 ›` 링크 44x44, 완료 표시는 본문, 제목 한 줄 `FittedBox` 축소), `exam_schedule_card.dart`(양끝 정렬 제거로 빈 공간 제거), `topic_card.dart`(`최신 경향` 배지 → 불꽃 아이콘, 스크린리더 "최신 경향").
- 탭과 프로필: 하단 탭 홈/문제/토론/내 프로필 4개, 기록+MY를 `내 프로필`로 합침(`stats_page.dart`, `profile_section.dart` 신규), 톱니바퀴로 설정을 push 화면으로 — [[DEC-0171-four-tabs-merge-stats-my-profile]]. `AppRoutes.tabRoots`에서 설정 제외, 푸시·딥링크 `stats`는 내 프로필 탭.
- 설정: `theme_mode_tile.dart` 화면 모드는 시트 없이 `자동 | 라이트 | 다크` 세그먼트. 차단 안내 "MY에서 언제든 해제" → "설정에서 언제든 해제".
- 레이아웃: `Expanded`·`Flexible`·`Wrap`·`FittedBox(scaleDown)`, 기기별 분기 없음 — [[DEC-0172-flexible-layout-no-fixed-sizes]].

## 근본 원인 (확정)
원본 리포트에 별도 원인 서술 없음. 이슈 본문의 두 공통 원인이 출발점이고, 수정은 "사본을 고치지 않고 공통 지점에서" 했다.

## 재발 방지
- 검증: 폭 320/375/430 × 글자 1.0/1.5/2.0 넘침 없음(임시 검사, 저장소 미반영). CI `분석과 테스트` 통과(1차 CI에서 옛 테스트 5건·구조 규칙 1건 위반 → 신고 아이콘을 공통 시맨틱 버튼으로, 이용권 칩 중복 제거). 에뮬레이터에서 홈·내 프로필·설정 push·뒤로가기·화면 모드·하단 바 확인, `3eb5d183`로 홈 제목 한 줄 확인.
- 테스트 정책: [[DEC-0173-no-new-tests-in-repo]] — 새 테스트는 올리지 않고 깨진 옛 테스트만 삭제(`report_flow_test.dart`, `app_shell_test.dart` 등). `design_system_rules_test` 등 아키텍처 규칙 테스트는 통과.
- 배포: main 1.43.0, Android 1.43.1 internal·alpha(production은 GitHub #568). iOS 1.43.0 첫 제출은 `You cannot create a new version of the App in the current state`(1.41.0이 `PENDING_DEVELOPER_RELEASE`) → 1.41.0 출시 후 1.43.0 심사 대기, 1.43.1 수정분은 다음 iOS 버전.
- 의도적으로 하지 않은 것: 모드 이름 통일(#7), 기록 길이(#10), 로그인 버튼(#11), AI 해설 독의 X.

## 교훈
(원본에 없음, 볼트 정리) 화면 하나의 UI 지적은 공통 컴포넌트 사용처 전체를 같이 본다. 좁은 폭·큰 글자 조합 검사는 main 기존 코드의 넘침도 함께 드러낸다.
