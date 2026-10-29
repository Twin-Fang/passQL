---
type: issue
id: ISS-0012
created: 2026-04-07
topics: [design-system]
symptoms: ["빈 스캐폴딩", "화면 UI 미구현", "mock 데이터", "반응형 레이아웃", "Prompt 0~7"]
root_cause: "디자인 시스템은 있었으나 실제 페이지는 빈 스캐폴딩 상태였다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0012-design-system-screen-ui-report]]"
related: ["[[DEC-0017-fullscreen-result-screen]]"]
source: "https://github.com/Twin-Fang/passQL/issues/9"
---

# ISS-0012: 디자인 시스템 기반 전체 화면 UI 구현

GitHub #9 (원본: 이슈 본문과 댓글).

## 증상
디자인 시스템(테마, 토큰, 타이포그래피, 컴포넌트 스타일)은 구축됐지만 페이지는 빈 스캐폴딩이었다. 8개 프롬프트(Prompt 0~7)로 화면별 디자인 스펙이 정의되어 있었고, Mobile 375px / Desktop 1280px(720px 콘텐츠) 반응형이 필요했다. API 연동 전에 UI 레이아웃을 먼저 잡아야 병렬 작업이 가능했다.
범위: Prompt 0(디자인 시스템 보정, 공용 컴포넌트) ~ Prompt 7(설정). API 연동은 별도 이슈.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-07: 프론트 담당 작업 보고 (아래 리포트).

## 근본 원인
해당 없음 (기능 이슈).
