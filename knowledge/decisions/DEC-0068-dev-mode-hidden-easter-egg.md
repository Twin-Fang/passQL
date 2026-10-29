---
type: decision
id: DEC-0068
created: 2026-04-13
reviewed: null
topics: [dev-workflow]
status: archived
supersedes: null
superseded_by: null
related: ["[[ISS-0115-developer-mode-easter-egg-unlock]]", "[[ISS-0115-developer-mode-easter-egg-unlock-report]]"]
---

# DEC-0068: 웹 개발자 기능은 숨기고 버전 row 5회 클릭으로 탭 세션 동안만 잠금 해제, `/dev` 페이지는 route guard

## 문제 정의 (Context)
설정 화면 개발자 섹션(localStorage 초기화)이 모든 사용자에게 노출되어 혼란·오작동 위험이 있었다 (GitHub #208).

## 결정 (Decision)
- 개발자 기능은 기본 숨김. 설정의 버전 row를 2초 debounce 안에 5번 연속 클릭하면 잠금 해제.
- 잠금 해제 상태는 `sessionStorage`(`devUnlocked`)에 둔다 — 탭 세션 동안 유지, 탭을 닫으면 해제.
- 개발자 기능은 별도 `/dev` 페이지로 분리하고 `DevGuard`가 URL 직접 진입을 막는다.
- localStorage 초기화는 2단계 확인, 경고는 toast가 아닌 인라인 텍스트.

## 검토한 대안 (Alternatives)
- React state만 사용: 다른 페이지에 갔다 오면 row가 사라지는 버그 때문에 쓰지 않음(리포트).
- 이슈 본문의 "새로고침 시 다시 숨겨짐": 구현은 sessionStorage라 같은 탭에선 유지된다. sessionStorage를 고른 이유로 리포트는 탭 세션 동안 유지 + `localStorage.clear()`에 영향받지 않음을 적었다.
- 경고 toast: 긴 경고 메시지가 toast 레이아웃을 깨서 인라인 텍스트로 바꿈.
- 매 클릭 2초 타이머 재시작(debounce): "잠깐 쉬어도 허용하는 Easter egg 특성에 적합"(리포트). 다른 방식과의 비교는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 일반 사용자에게 개발자 기능이 보이지 않고, 모바일에서도 콘솔 없이 초기화 가능.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
웹 `Settings.tsx`, `SettingsRow.tsx`, `DevPage.tsx`, `App.tsx`(`/dev` 라우트, `DevGuard`).

## 출처 (References)
- GitHub #208 이슈 본문, 작업 리포트 「주요 설계 결정」 (2026-04-13)
- [[ISS-0115-developer-mode-easter-egg-unlock]]
