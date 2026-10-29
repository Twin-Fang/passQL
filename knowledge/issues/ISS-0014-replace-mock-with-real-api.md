---
type: issue
id: ISS-0014
created: 2026-04-07
topics: [dev-workflow]
symptoms: ["mock 데이터", "API 미연동", "카드 클릭 라우팅 미연결", "TanStack Query 훅 없음", "execute submit 미동작"]
root_cause: "7개 화면 UI가 mock 상수로 구현되어 백엔드와 통신하지 않았다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0014-replace-mock-with-real-api-report]]"
related: ["[[DEC-0016-auto-execute-on-choice-click]]"]
source: "https://github.com/Twin-Fang/passQL/issues/13"
---

# ISS-0014: Mock 데이터 → 실제 API 연동

GitHub #13 (원본: 이슈 본문과 댓글).

## 증상
7개 화면 UI가 mock 상수로 되어 있어 백엔드와 통신하지 않았다. 카드 클릭 → 상세 라우팅 미연결, 선택지 execute·submit·AI 해설 등 핵심 인터랙션 미동작, TanStack Query 훅 없음.
제안: `be-api-docs.json`(OpenAPI v0.0.3) 기준 구현 완료 엔드포인트 11개 연동, 미구현 API(members, today, recent-wrong)는 에러 시 섹션 숨김, `apiFetch<T>()` + TanStack Query 훅 패턴 통일, 선택지 자동 실행 캐시(`Record<choiceKey, ExecuteResult>`), `ApiError` 기반 에러 처리 통일.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-08: 프론트 담당 작업 보고 (아래 리포트). 신규 회원으로 `/api/progress`, `/api/meta/topics`, `/api/questions` 호출 시 백엔드 500을 관찰했다고 적었다.
- 2026-04-22: 백엔드 담당 작업 완료 보고 — 이후 GitHub #41, #67, #68, #78, #101로 개선, JWT 인증 기반 API 클라이언트 전환(GitHub #121)까지 완료.

## 근본 원인
해당 없음 (기능 이슈).
