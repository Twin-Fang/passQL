---
type: completion-report
id: ISS-0098
created: 2026-04-12
topics: [design-system]
status: resolved
resolves: "[[ISS-0098-applayout-nav-daisyui-classes]]"
related: ["[[DEC-0064-force-light-passql-theme]]"]
source: "https://github.com/Twin-Fang/passQL/issues/179"
---

# ISS-0098 완료 리포트: 하단 탭은 daisyUI dock, 사이드바는 Tailwind 직접 적용, 테마 고정

GitHub #179 작업 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `src/components/AppLayout.tsx` `BottomTabNav`: `nav-tab*` → `dock`, `dock-active`, `dock-label`. `h-14`로 dock 기본 높이(64px)를 56px로 재정의.
- `SidebarNav`: `menu` 대신 `flex flex-col gap-1` 컨테이너 + NavLink className에 Tailwind 직접 지정(활성 `bg-accent text-primary`, 비활성 `text-base-content/60 hover:bg-base-200`).
- `src/styles/components.css`: `nav-tab*`, `nav-sidebar-item*` 6개 블록(44줄) 제거.
- `index.html`: `<html>`에 `data-theme="passql"` 추가 → [[DEC-0064-force-light-passql-theme]].

## 근본 원인 (확정)
커스텀 CSS 의존. `menu`의 `li a` 자동 스타일이 NavLink className 함수와 충돌했다.

## 재발 방지
리포트 참고사항: daisyUI 5에서 dock 활성 클래스는 `active`가 아니라 `dock-active`(daisyUI 4와 다름). `menu`가 NavLink와 충돌하면 `flex flex-col gap-1` 직접 구성으로 우회. 검증: 모바일(< 1024px) dock, 데스크톱(>= 1024px) 사이드바, OS 다크모드와 무관하게 라이트 테마 유지 확인.

## 교훈
(원본에 없음, 볼트 정리) 웹이 OS 다크모드에서 갑자기 어두워지면 `<html data-theme>` 고정 여부부터 본다.
