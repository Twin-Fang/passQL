---
type: decision
id: DEC-0124
created: 2026-10-15
reviewed: null
topics: [design-system, ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0265-brand-assets-single-source]]", "[[ISS-0265-brand-assets-single-source-report]]", "[[DEC-0118-single-source-commonization-rules]]", "[[DEC-0121-unified-brand-color]]"]
---

# DEC-0124: 브랜드 자산 원본은 레포 루트 `brand/` 하나, 플랫폼 사본은 스크립트로만 생성하고 CI 해시 검사

## 문제 정의 (Context)
로고·아이콘·색이 여러 플랫폼에 손으로 복사돼 #453처럼 한 곳만 고치고 나머지를 놓쳤다 (GitHub #459).

## 결정 (Decision)
루트 `brand/`를 원본으로 둔다. `generate_brand_assets_for_all_platforms.py` 하나로 모든 플랫폼 사본(27개)을 만든다. CI(`PROJECT-COMMON-BRAND-ASSETS-CHECK.yaml`)가 원본·사본 경로 변경 시 `--check`로 해시 비교해 사본만 손으로 고친 PR을 막는다. 사본을 직접 고치지 않는다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이전 상태는 플랫폼별 수동 복사.)

## 결과 (Consequences)
**긍정**
- 관리자·OG 로고 갱신, Android 11 이하 시작 화면 로고 추가.

**부정**
- 스토어 스크린샷은 생성 대상이 아니라 따로 다시 찍어야 한다.

## 영향 범위 (Scope)
`brand/`, `app/assets/`, `app/ios/Runner/Assets.xcassets/LaunchImage.imageset`, Android `drawable-*`, 웹 로고·OG·favicon, `server/PQL-Web/.../static/images/`, `.github/workflows/PROJECT-COMMON-BRAND-ASSETS-CHECK.yaml`.

## 출처 (References)
- GitHub #459 이슈 본문, 구현 보고서 (2026-10-15)
