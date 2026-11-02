---
type: decision
id: DEC-0232
created: 2026-11-01
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0437-app-settings-ui-ux-cleanup]]", "[[ISS-0437-app-settings-ui-ux-cleanup-report]]", "[[ISS-0363-app-wide-ui-ux-cleanup]]", "[[DEC-0116-app-apple-hig-design-system]]"]
---

# DEC-0232: 앱 설정 화면 모드는 설명 줄 없이 `기기 설정 | 라이트 | 다크` 세그먼트로 둔다

## 문제 정의 (Context)
설정 화면 모드 세그먼트(#602에서 시트 없이 `자동 | 라이트 | 다크`로 바꿈)는 '자동'일 때만 "기기의 라이트/다크 설정을 따라요" 한 줄이 붙어, 고를 때마다 아래 묶음이 움직였다. GitHub #774 세션 사용자 발언: "UI적으로 움직임이 있어서 불편함".

## 결정 (Decision)
- 화면 모드 줄에 보조 설명을 두지 않는다. 어느 칸을 골라도 줄 높이가 같다.
- 시스템 모드 칸 이름은 `기기 설정`. 세 칸 `기기 설정 | 라이트 | 다크`, 시트 없는 세그먼트는 유지한다.

## 검토한 대안 (Alternatives)
세션에서 비주얼 컴패니언으로 라이트·다크 한 쌍씩 비교했고, 사용자가 추천안을 골랐다 ("좋아 그렇게 하고").
- 설명만 빼고 '자동' 유지: iOS의 '자동'은 해 질 녘 기준 시간 전환이라 '기기 설정을 따른다'는 뜻이 흐려져 칸 이름을 바꿨다.
- 설명을 늘 두고 문구만 바꾸기: 라이트·다크 설명이 칸 이름을 되풀이하는 빈 문장이 된다.
- 고르는 줄 3개(카카오톡·YouTube 방식): 화면이 길어져 #774의 묶음 정리 방향과 반대.
- iOS 디스플레이 및 밝기식 미리보기 + 자동 스위치: 거의 안 바꾸는 설정치고 새 부품 비용이 크다.
- 값 줄 + 시트: #602에서 시트를 없앤 결정을 되돌리게 되어 후보에서 뺐다.
- 참고로 Apple HIG는 앱별 화면 모드 설정을 두지 말라고 권하지만, 설정 자체를 없애는 것은 논의하지 않았다.

## 결과 (Consequences)
**긍정**
- 화면 모드를 바꿔도 화면이 움직이지 않는다 (전후 영상 확인).

**부정**
- '자동'보다 칸 이름이 길다. 논의 기록 없음 (폭 문제는 iPhone 16 Pro 캡처에서만 확인).

## 영향 범위 (Scope)
`app/lib/presentation/widgets/settings/theme_mode_tile.dart` (`themeModeLabel`, `ThemeModeTile`). 저장값 `ThemeMode.system`은 그대로다.

## 출처 (References)
- GitHub #774 이슈·리포트 댓글 6551234349 (2026-11-01), 구현 세션 대화
- [[ISS-0437-app-settings-ui-ux-cleanup]]
