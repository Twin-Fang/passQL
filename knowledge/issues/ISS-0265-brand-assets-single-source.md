---
type: issue
id: ISS-0265
created: 2026-10-15
topics: [design-system, ci-deploy]
symptoms: [로고 사본 따로, 관리자 흰 배경 로고, OG 이미지 옛 로고, Android 시작 화면 로고 없음, 사본 수정 누락]
root_cause: "로고·아이콘·OG·파비콘 사본이 앱·iOS 시작 화면·Android·웹·관리자에 손으로 복사돼 있었다"
status: resolved
resolution: "[[ISS-0265-brand-assets-single-source-report]]"
related: ["[[DEC-0124-brand-folder-generated-assets]]", "[[DEC-0118-single-source-commonization-rules]]", "[[ISS-0259-dark-mode-logo-white-background]]", "[[DEC-0121-unified-brand-color]]"]
source: "https://github.com/Twin-Fang/passQL/issues/459"
---

# ISS-0265: 브랜드 자산 사본이 플랫폼마다 따로 있어 수정이 빠짐

GitHub #459 (원본: 이슈 본문과 구현 보고서). 상위 GitHub #458.

## 증상
로고·아이콘·OG·파비콘 사본이 앱·iOS 시작 화면·Android·웹·관리자에 따로 있다. 관리자 화면과 OG 이미지는 아직 옛 흰 배경 로고, Android 시작 화면에는 로고가 없다.

## 재현 조건
해당 없음 (구조 문제). 예: GitHub #453에서 한 곳만 고치고 iOS 시작 화면을 놓침.

## 조사 기록
- 2026-10-15: 기준 — 상위 #458, 검수 보고서 `docs/ARCHITECTURE-AUDIT.md`, 동작은 바꾸지 않고 구조만.

## 근본 원인
frontmatter `root_cause`와 같음.
