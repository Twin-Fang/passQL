---
type: issue
id: ISS-0051
created: 2026-04-11
topics: [ci-deploy, practice]
symptoms: ["405 Method Not Allowed", passql.vercel.app, generate-choices, BASE_URL, VITE_API_BASE_URL, "fetch('/api/...') 하드코딩", "로컬은 정상"]
root_cause: "generateChoices()가 fetch('/api/...')를 하드코딩했고 BASE_URL 폴백이 Vite 프록시용 /api뿐이라 prod에서 요청이 Vercel 도메인으로 갔다 (이슈 본문 참고 자료)"
status: resolved
resolution: "[[ISS-0051-vercel-generate-choices-405-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/94"
---

# ISS-0051: Vercel 프로덕션에서 `generate-choices`가 405

GitHub #94 (원본: 이슈 본문과 댓글).

## 증상
`passql.vercel.app`에서 선택지 생성 SSE 요청이 405로 실패한다. 요청이 `<API 서버>/api/...`가 아니라 `https://passql.vercel.app/api/...`로 간다. 로컬은 정상.

## 재현 조건
Vercel 배포본에서 문제 풀기 진입 → 네트워크 탭의 `generate-choices` 요청 확인(Pixel 7, Android 13, Chrome 146에서 보고).

## 조사 기록
- 2026-04-11: 이슈 본문 참고 자료 — `client/src/api/questions.ts`의 `generateChoices()`가 `fetch('/api/...')` 하드코딩, `client/src/api/client.ts`의 `BASE_URL` 폴백이 `/api`뿐.

## 근본 원인
SSE 함수가 공통 `BASE_URL`을 쓰지 않았고 prod용 기본값이 없었다.
