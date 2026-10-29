---
type: issue
id: ISS-0230
created: 2026-10-07
topics: [design-system]
symptoms: ["Unexpected Application Error!", "Hey developer", "React Router 기본 에러 화면", errorElement, "* 라우트 없음", "404 Not Found"]
root_cause: "라우터에 전체를 받는 `*` 라우트와 `errorElement`가 없었다"
status: resolved
resolution: "[[ISS-0230-web-react-router-default-error-screen-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/397"
---

# ISS-0230: 없는 경로에서 React Router 개발자 에러 화면이 노출됨 (웹)

GitHub #397 (원본: 이슈 본문과 완료 댓글).

## 증상
존재하지 않는 주소로 들어가면 React Router 기본 에러 화면("Unexpected Application Error! 404 Not Found / Hey developer 👋")이 영어 그대로 노출된다. 콘솔: `Error handled by React Router default ErrorBoundary: {"status":404,"statusText":"Not Found",...}`. 렌더 중 런타임 예외도 같은 화면이 보일 것으로 판단(이슈 작성자 추정).

## 재현 조건
운영 E2E(2026-10-08, Playwright Chromium 375/768/1280). https://passql.vercel.app/no-such-page 접속(`/login/extra`도 동일).

## 조사 기록
- 2026-10-07: 코드 `client/src/App.tsx` 라우터 정의 — `*` 라우트와 `errorElement`가 레포 전체에 없음.

## 근본 원인
라우터에 404·에러 경계가 없었다.
