---
type: issue
id: ISS-0008
created: 2026-04-07
topics: [dev-workflow, design-system]
symptoms: ["client 빈 디렉토리", ".gitkeep", Vite, React, "4탭 SPA", "프론트 부트스트랩"]
root_cause: "`client/`가 `.gitkeep`만 있는 빈 상태라 프론트 개발을 시작할 수 없었다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0008-react-client-initial-setup-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/5"
---

# ISS-0008: React Client 초기 프로젝트 구성

GitHub #5 (원본: 이슈 본문과 댓글).

## 증상
`client/`가 `.gitkeep`만 있는 빈 상태로 프론트엔드 개발을 시작할 수 없었다. PRD의 4탭 SPA(홈/문제/통계/설정)와 문제 상세 화면 구현 기반이 필요했고, 6일 데드라인 MVP를 위해 최소 의존성으로 부트스트랩해야 했다.
제안: Vite + React 18 + TypeScript로 초기화. `react-router-dom`, `@tanstack/react-query`, `zustand`, `tailwindcss` v4 + `daisyui` v5만 우선 도입. CodeMirror, Recharts, react-markdown 등 특정 화면 전용 라이브러리는 해당 화면 구현 시점에 추가. `api/client.ts` fetch wrapper(25초 timeout, ApiError), 회원 등록/조회(`POST /api/members/register`, `GET /api/members/me`), `vercel.json`(`/api/*` 리라이트, SPA fallback).

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-07: 백엔드 담당이 백엔드 도메인과 Swagger 주소를 공유.
- 2026-04-07: 프론트 담당 작업 보고 (아래 리포트).
- 2026-04-08: 백엔드 담당이 배포 주소(`/stats`) 확인 후 작업 완료 처리.

## 근본 원인
해당 없음 (기능 이슈).
