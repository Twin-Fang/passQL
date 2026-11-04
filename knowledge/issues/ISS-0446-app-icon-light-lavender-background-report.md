---
type: completion-report
id: ISS-0446
created: 2026-11-04
topics: [design-system, store-release]
status: resolved
resolves: "[[ISS-0446-app-icon-light-lavender-background]]"
related: ["[[DEC-0242-app-icon-lavender-two-line-pass-ql]]", "[[DEC-0124-brand-folder-generated-assets]]", "[[ISS-0265-brand-assets-single-source-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/766"
---

# ISS-0446 완료 리포트: 앱 아이콘을 시안 8번(연보라 그라데이션 + pass/QL 2줄)으로, 가로 로고에서 합성

GitHub #766 리포트 기준 (2026-11-04). 원본 사본: `_sources/issues/ISS-0446-app-icon-light-lavender-background-report.md` (로컬 전용). PR #818로 2026-11-04 main에 머지됐다.

> 배포 상태: 작성 시점(2026-11-04)에 #817 릴리스 뒤 머지돼 아직 배포되지 않았다. 다음 릴리스에 웹·서버 favicon이 바뀌고, 앱 아이콘은 스토어 새 버전에서 바뀐다.

## 해결 방법
- **시안 8번:** 연보라 세로 그라데이션(`#F7F6FF` > `#ECEBFF`) 위에 `pass`(남색)와 `QL`(원본 그라데이션보다 18% 진하게)을 2줄로 올렸다 → [[DEC-0242-app-icon-lavender-two-line-pass-ql]].
- **`brand/compose_app_icon.py` (신규):** 가로 로고(`brand/logo_horizontal.png`)에서 `pass`·`QL`을 잘라 아이콘 원본 2개를 합성한다.
  - `app_icon_1024.png`: 불투명 그라데이션 배경 (App Store 아이콘은 알파 금지)
  - `app_icon_adaptive_foreground.png`: 투명 전경, Android 원형 안전 영역(지름 66%) 안에 묶음 폭 50%
  - `pass`/`QL` 경계는 가로 로고의 열별 채도로 측정한 값(788/815)을 상수로 뒀다.
- **`brand/brand-colors.json`:** `appIconBackground` `#060C26` > `#F2F1FF`, `appIconGradient` 추가. `brand/README.md`에 합성 명령과 원본 설명.
- **사본 재생성:** iOS AppIcon 20종, Android mipmap·적응형 전경 5종, `colors.xml` `ic_launcher_background`, `pubspec.yaml` `adaptive_icon_background`(`#F2F1FF`), 웹 favicon·앱 아이콘, 서버 favicon.
- **검증:** `generate_brand_assets_for_all_platforms.py --check`에서 사본 28개가 모두 원본과 일치, CI `PASSQL-BRAND-ASSETS-CHECK` 통과. 58px 홈 화면 크기 미리보기(밝은·어두운 배경화면)에서 `pass QL`이 읽히고, 적응형 원형으로 잘려도 글자가 남는다.

## 근본 원인 (확정)
어두운 남색 배경(`#060C26`)과 보라 > 하늘 그라데이션 글자의 대비가 작은 크기에서 부족했다.

## 재발 방지
- 아이콘을 손으로 그리지 않고 가로 로고 하나에서 합성한다. 로고가 바뀌면 `compose_app_icon.py` > `generate_brand_assets_for_all_platforms.py` > `flutter_launcher_icons` 순서로 모든 플랫폼이 같이 바뀐다 (단일 원본 기준은 [[DEC-0124-brand-folder-generated-assets]]).

## 알고 남긴 것
- 앱 아이콘은 스토어에 새 버전이 나가야 사용자 기기에 바뀐다. 웹·서버 favicon은 배포만 하면 바뀐다.
- Play 스토어 목록 아이콘(512px)은 Play Console에서 따로 올려야 한다.
- iOS 다크·틴트 아이콘은 따로 만들지 않았다 (같은 아이콘).
- 밝은 배경화면 위에서는 아이콘 경계가 옅다 (시안 8번 특성, 10번처럼 테두리를 넣으면 보완 가능).

## 교훈
(원본의 검증·주의 항목에서 정리)
- 아이콘 시안은 1024px 원본이 아니라 홈 화면 크기(58px 안팎)를 밝은·어두운 배경화면에 놓고 비교한다.
- 스토어 목록 아이콘은 레포 생성 대상이 아니다. 아이콘을 바꾸면 Play Console 업로드를 따로 챙긴다.
