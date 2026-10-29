---
type: completion-report
id: ISS-0265
created: 2026-10-15
topics: [design-system, ci-deploy]
status: resolved
resolves: "[[ISS-0265-brand-assets-single-source]]"
related: ["[[DEC-0124-brand-folder-generated-assets]]"]
source: "https://github.com/Twin-Fang/passQL/issues/459"
---

# ISS-0265 완료 리포트: `brand/` 원본에서 사본 27개 생성, CI `--check`

GitHub #459 구현 보고서(2026-10-15) 기준.

## 해결 방법
- 원본 `brand/`: `logo_horizontal.png`, `app_icon_1024.png`, `app_icon_adaptive_foreground.png`, `brand-colors.json`(`#5856D6`, 다크 `#5E5CE6`), `generate_brand_assets_for_all_platforms.py`(사본 27개 생성, `--check`), `brand_color_consistency.py`, `README.md`.
- 생성 사본: 앱 `assets/logo.png`·`logo_dark.png`, iOS `LaunchImage` 라이트·다크, Android 11 이하 시작 화면 `launch_logo`(drawable-{밀도}, drawable-night-{밀도}) 신규, 웹 로고·`og-image`(1200x630)·favicon, 관리자 `static/images/logo.png`(투명 새 로고)·`logo_dark.png`(신규)·`favicon.ico`.
- 참조 없는 `app_icon_512.png` 삭제. CI `PROJECT-COMMON-BRAND-ASSETS-CHECK.yaml`.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 원본: "사본을 직접 고치지 않습니다." `brand/` 원본을 고치고 스크립트를 다시 돌린다. 사본만 고치면 CI가 실패한다.
- 검증: `python3 brand/generate_brand_assets_for_all_platforms.py --check` 27개 일치, iOS 시뮬레이터 시작 화면 라이트·다크, 운영 관리자 테마별 로고 전환.
- 주의(원본): Android 12 이상은 시스템 스플래시(앱 아이콘) — `launch_logo`는 Android 11 이하에서만 보이며 실기기 캡처는 못 함. 스토어 스크린샷은 생성 대상이 아님(#457).

## 교훈
원본 재발 방지 문장과 같음.
