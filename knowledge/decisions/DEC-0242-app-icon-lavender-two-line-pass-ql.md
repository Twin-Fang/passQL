---
type: decision
id: DEC-0242
created: 2026-11-04
reviewed: null
topics: [design-system, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0446-app-icon-light-lavender-background]]", "[[ISS-0446-app-icon-light-lavender-background-report]]", "[[DEC-0124-brand-folder-generated-assets]]", "[[DEC-0121-unified-brand-color]]"]
---

# DEC-0242: 앱 아이콘은 시안 8번 — 연보라 세로 그라데이션(`#F7F6FF` > `#ECEBFF`) 위 `pass`(남색) + `QL`(18% 진하게) 2줄, 가로 로고에서 합성하고 다크·틴트 아이콘은 따로 두지 않는다

## 문제 정의 (Context)
앱 아이콘 배경이 어두운 남색(`#060C26`)이라 홈 화면 크기에서 보라 > 하늘 그라데이션 `QL`이 배경과 섞여 읽히지 않았다 (GitHub #766). 아이콘에 관한 기존 활성 결정은 없었고, 사본 생성 방식만 [[DEC-0124-brand-folder-generated-assets]]가 정하고 있다.

## 결정 (Decision)
- **디자인:** 시안 8번. 연보라 세로 그라데이션(`#F7F6FF` > `#ECEBFF`) 배경, `pass`는 남색, `QL`은 원본 그라데이션보다 18% 진하게, 2줄.
- **원본:** `brand/compose_app_icon.py`가 `brand/logo_horizontal.png`에서 아이콘 원본 2개(불투명 `app_icon_1024.png`, 투명 적응형 전경 `app_icon_adaptive_foreground.png`)를 합성한다. 아이콘을 손으로 그리지 않는다.
- **배경색 원본:** `brand/brand-colors.json` `appIconBackground` `#F2F1FF`(Android 적응형 배경 단색) + `appIconGradient`.
- **다크·틴트:** iOS 다크·틴트 아이콘은 따로 만들지 않고 같은 아이콘을 쓴다 (리포트 "같은 아이콘").

## 검토한 대안 (Alternatives)
이슈 본문의 시안 10개 중 8번을 골랐다. 본문 표에 적힌 각 시안의 특징:
- 1 흰색 + QL: 가장 단순하나 하늘색 끝부분이 흐려짐.
- 2 연보라 + QL 진하게, 3 연회청 + QL 진하게: 작은 크기에서 또렷함 / 차분함.
- 4 흰색 + 보라 단색 QL: 대비가 가장 안정적이나 그라데이션 개성이 줄어듦.
- 5·6 보라 계열 배경 + 흰 QL: 가장 눈에 띄지만 밝은 배경이 아님 / 화려함.
- 7 흰색 + passQL 가로 로고: 앱 이름이 다 보이지만 작은 크기에서 글자가 너무 작음.
- 9 밝은 남색 + 흰 QL: 지금 분위기 유지.
- 10 흰색 + 연보라 테두리: 흰 배경화면에서도 경계가 보임.
8번을 고른 이유는 본문의 특징 설명("앱 이름을 살리면서 QL을 크게 유지") 외에 따로 기록되지 않았다 (논의 기록 없음).

## 결과 (Consequences)
**긍정**
- 58px 홈 화면 크기에서 밝은·어두운 배경화면 모두 `pass QL`이 읽히고, 적응형 원형으로 잘려도 글자가 남는다 (리포트 검증).
- 로고가 바뀌면 합성 > 사본 생성 > `flutter_launcher_icons` 순서로 모든 플랫폼이 같이 바뀐다.

**부정**
- 밝은 배경화면 위에서는 아이콘 경계가 옅다 (10번처럼 테두리를 넣으면 보완 가능).
- 앱 아이콘은 스토어 새 버전이 나가야 사용자 기기에 바뀌고, Play 스토어 목록 아이콘(512px)은 Play Console에서 따로 올려야 한다.

## 영향 범위 (Scope)
`brand/compose_app_icon.py`, `brand/app_icon_1024.png`, `brand/app_icon_adaptive_foreground.png`, `brand/brand-colors.json`, `brand/README.md`, iOS AppIcon, Android mipmap·적응형 전경·`colors.xml` `ic_launcher_background`, `app/pubspec.yaml` `adaptive_icon_background`, 웹 `client/public/favicon.png`·`client/src/assets/logo/app_icon.png`, 서버 `static/favicon.ico`, Play Console 목록 아이콘(수동).

## 출처 (References)
- GitHub #766 이슈 본문(시안 10개 표), 리포트 (2026-11-04), PR #818
- 이슈: [[ISS-0446-app-icon-light-lavender-background]], 리포트 [[ISS-0446-app-icon-light-lavender-background-report]]
