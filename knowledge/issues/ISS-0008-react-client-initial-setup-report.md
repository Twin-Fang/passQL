---
type: completion-report
id: ISS-0008
created: 2026-04-07
topics: [dev-workflow, design-system]
status: resolved
resolves: "[[ISS-0008-react-client-initial-setup]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/5"
---

# ISS-0008 완료 리포트: Vite + React 19 + TypeScript SPA 부트스트랩

GitHub #5 프론트 담당 작업 보고 댓글(2026-04-07) 기준. `## 개요` 형식이 아니라 「작업 개요」 형식이다. 완료 처리 댓글은 2026-04-08.

## 해결 방법
- Vite 8 + React 19 + TypeScript 6 (이슈 본문은 React 18이었으나 실제는 React 19). `@vitejs/plugin-react-swc`. 개발 서버 `/api` 프록시.
- 의존성: react / react-dom `19.2.4`, react-router-dom `7.14.0`, @tanstack/react-query `5.96.2`, zustand `5.0.12`, tailwindcss `4.2.2`, daisyui `5.5.19`, vite `8.0.4`, typescript `6.0.2`.
- `createBrowserRouter`로 5개 라우트(`/`, `/questions`, `/questions/:id`, `/stats`, `/settings`). `AppLayout`에서 Desktop 사이드바(220px) / Mobile 하단 탭 반응형 전환.
- `src/api/client.ts` `apiFetch<T>()`: 25초 타임아웃(`AbortController`), `ApiError`(status, body).
- `src/types/api.ts`: API 응답 타입 15개를 `readonly` interface로 정의.
- `src/stores/memberStore.ts`: 회원 등록 API가 백엔드 미구현이라 `crypto.randomUUID()`로 클라이언트 UUID를 만들어 `localStorage`에 저장, `X-User-UUID` 헤더 주입.
- TanStack Query: `staleTime: 5분`, `retry: 1`.
- 디자인 시스템: daisyUI 커스텀 테마(`passql`, Deep Indigo), CSS 토큰, Pretendard 단일 UI 폰트, 12종 컴포넌트 스타일. 홈 화면은 Mock 데이터.
- `vercel.json`: `/api/*` 리라이트, SPA fallback.
- 검증: `npm run dev`, 4탭 전환, 반응형 전환, 홈 Mock 렌더링 확인.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
리포트 참고사항: 백엔드 미구현 API(Members, Questions today, Progress recent-wrong) 호출부는 에러 시 섹션 숨김 예정. 클라이언트 UUID 방식은 백엔드 구현 후 서버 발급 UUID로 전환 필요. CodeMirror·Recharts·react-markdown은 해당 화면 구현 시 설치 예정.

## 교훈
원본에 적혀 있지 않다.
