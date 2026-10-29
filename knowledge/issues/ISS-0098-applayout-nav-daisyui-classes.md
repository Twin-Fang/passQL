---
type: issue
id: ISS-0098
created: 2026-04-12
topics: [design-system]
symptoms: [AppLayout, nav-tab, nav-sidebar-item, "하단 탭", "사이드바", "OS 다크모드 자동 적용", data-theme]
root_cause: "AppLayout 하단 탭·사이드바가 커스텀 CSS 클래스로 구현되어 있었다"
status: resolved
resolution: "[[ISS-0098-applayout-nav-daisyui-classes-report]]"
related: ["[[DEC-0064-force-light-passql-theme]]"]
source: "https://github.com/Twin-Fang/passQL/issues/179"
---

# ISS-0098: AppLayout 네비게이션에 daisyUI 클래스 적용

GitHub #179 (원본: 이슈 본문과 작업 리포트 댓글).

## 증상
`AppLayout`의 모바일 하단 탭(`nav-tab`, `nav-tab--active`, `nav-tab--inactive`)과 데스크톱 사이드바(`nav-sidebar-item`, `nav-sidebar-item--active`)가 커스텀 CSS 클래스. 전체 페이지 공통 컴포넌트라 daisyUI 전환 효과가 가장 크다(이슈 본문).

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 등록. 제안: 하단 탭 → daisyUI `dock`, 사이드바 → `menu`, 인디고 브랜드 색 유지.
- 2026-04-12: 작업 중 `menu` 클래스의 `li a` 자동 스타일이 NavLink className 함수와 충돌해 활성/비활성 스타일이 안 먹는 문제 발견. 또 OS 다크모드에 따라 daisyUI가 다크 테마를 자동 적용하는 문제 발견.

## 근본 원인
커스텀 네비게이션 CSS가 남아 있었다. 다크 테마 자동 적용은 `<html>`에 테마가 고정되어 있지 않았기 때문.
