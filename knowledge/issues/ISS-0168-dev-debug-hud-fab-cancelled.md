---
type: issue
id: ISS-0168
created: 2026-04-27
topics: [dev-workflow]
symptoms: ["개발자 모드", "디버그 HUD", DevFab, "Speed Dial", "API 로그 패널", devMode, "Easter Egg 제거"]
root_cause: "해당 없음 — 기능 추가, 취소로 닫힘"
status: resolved
resolution: null
related: ["[[ISS-0165-settings-logout-button-ux]]"]
source: "https://github.com/Twin-Fang/passQL/issues/314"
---

# ISS-0168: 개발자 디버그 HUD FAB 구현

GitHub #314 (원본: 이슈 본문과 댓글 2개). GitHub 상태는 closed(completed), 라벨 `취소`.

취소로 닫힘: "웹 개발자 디버그 HUD는 2026-04 시점의 웹 중심 기획이라 현재 서비스(Flutter 앱 + 데일리 세트 중심 학습 흐름)와 맞지 않는 오래된 명세로 보고 취소한다. 필요하면 현재 기준으로 새 이슈를 만든다. 개발자 모드 Easter Egg 자체가 이미 제거된 상태였다."

## 증상
(현재 문제점) `client.ts`의 `log()`는 DEV에서 콘솔에만 출력해 개발자 도구를 열어야 한다. 개발자 모드(Easter Egg) 제거로 인앱 디버그 진입점이 없어졌다. API 응답 시간, AI 디버그 정보, Zustand 스토어 상태를 화면에서 볼 수단이 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-04-27 기획: 설정에 개발자 모드 토글(sessionStorage `devMode`), daisyUI Speed Dial FAB, 패널 3종(API 로그, AI 응답 디버거, Zustand 스토어 뷰어), `src/dev/` 폴더 분리, `import.meta.env.DEV`에서만 렌더링. 댓글: daisyUI FAB 사용 지시.
- 2026-10-07: 취소.

## 근본 원인
해당 없음.
