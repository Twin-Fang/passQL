---
type: issue
id: ISS-0446
created: 2026-11-04
topics: [design-system, store-release]
symptoms: ["앱 아이콘 글자 안 보임", "앱 아이콘 어두운 남색 배경", "홈 화면 크기 아이콘", "favicon 글자 흐림", "적응형 아이콘 배경", appIconBackground, "#060C26", ic_launcher_background, adaptive_icon_background, app_icon_1024.png, app_icon_adaptive_foreground.png, flutter_launcher_icons]
root_cause: "앱 아이콘 배경이 아주 어두운 남색(#060C26)이고 QL 글자가 보라 > 하늘 그라데이션이라, 60px 안팎으로 줄이면 배경과 보라색 Q가 섞여 글자가 읽히지 않았다"
status: resolved
resolution: "[[ISS-0446-app-icon-light-lavender-background-report]]"
related: ["[[ISS-0446-app-icon-light-lavender-background-report]]", "[[DEC-0242-app-icon-lavender-two-line-pass-ql]]", "[[DEC-0124-brand-folder-generated-assets]]", "[[DEC-0121-unified-brand-color]]", "[[ISS-0170-app-icon-favicon-registration]]"]
source: "https://github.com/Twin-Fang/passQL/issues/766"
---

# ISS-0446: 앱 아이콘 배경을 밝게 — 어두운 남색 배경에서 글자가 안 보임

GitHub #766 이슈 본문 기준. 원본 사본: `_sources/issues/ISS-0446-app-icon-light-lavender-background.md` (로컬 전용). 완료 리포트: [[ISS-0446-app-icon-light-lavender-background-report]]

## 증상
- 앱 아이콘 배경이 아주 어두운 남색(`#060C26`)이고, 글자 `QL`은 보라색에서 하늘색으로 바뀌는 그라데이션이다.
- 홈 화면 크기(약 60px)로 줄이면 배경과 보라색 Q가 섞여 글자가 잘 안 보인다.
- 기대: 홈 화면·스토어 목록·웹 favicon 같은 작은 크기에서도 `QL`(또는 `passQL`)이 바로 읽히고, 밝은·어두운 배경화면 모두에서 윤곽이 보이며, iOS·Android 앱 아이콘, Android 적응형 아이콘 배경, 웹·서버 favicon이 같은 디자인으로 맞춰진다.

## 재현 조건
홈 화면(58px 안팎)에 아이콘을 놓으면 어느 배경화면에서나 글자가 흐리다. 원본은 `brand/app_icon_1024.png`, `brand/app_icon_adaptive_foreground.png`, `brand/brand-colors.json`의 `appIconBackground`.

## 조사 기록
- 2026-10-30: 시안 10개(흰색·연보라·연회청·보라·밝은 남색 배경 등)를 1024px 원본과 58px 홈 화면 크기(밝은·어두운 배경)로 비교했다. 이슈 본문은 "하나를 확정한 뒤 반영(조합 가능)", `pass`를 넣으면 Android 적응형 전경도 새로 만들어 원형으로 잘려도 글자가 남는지 확인, 다크·틴트 아이콘 여부 결정을 추가 요청으로 적었다.
- 2026-11-04: 시안 8번(연보라 + pass/QL 2줄)으로 확정해 반영했다 → [[DEC-0242-app-icon-lavender-two-line-pass-ql]].

## 근본 원인
어두운 배경 + 보라 계열 그라데이션 글자 조합이 작은 크기에서 명도 대비가 부족했다.
