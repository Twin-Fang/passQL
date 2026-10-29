---
type: issue
id: ISS-0231
created: 2026-10-07
topics: [auth-member]
symptoms: ["액세스 토큰만 무효", "리프레시 토큰 없음", "홈에 갇힘", "401", apiFetch, passql_access_token]
root_cause: "`client/src/api/client.ts` apiFetch의 `if (!refreshToken) throw err;` 분기가 토큰 정리·로그인 이동을 하지 않았다"
status: resolved
resolution: "[[ISS-0231-web-invalid-access-token-stuck-home-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/398"
---

# ISS-0231: 액세스 토큰만 무효일 때 로그인으로 이동하지 않고 홈에 갇힘 (웹)

GitHub #398 (원본: 이슈 본문과 완료 댓글).

## 증상
저장된 액세스 토큰이 무효이고 리프레시 토큰이 없으면 API가 전부 401인데도 로그인 화면으로 보내지 않고 홈에 머문다. 인사말 이름이 빠지고 카드들이 빈 상태 문구만 보인다. 리프레시 토큰이 함께 있으면 재발급 401 후 `/login`으로 정상 이동한다.

## 재현 조건
localStorage에 `passql_access_token`만 임의 값으로 넣고 https://passql.vercel.app/ 접속 → 홈 API 7개 모두 401.

## 조사 기록
- 2026-10-07: 코드 `client/src/api/client.ts` apiFetch의 `if (!refreshToken) throw err;` 분기.

## 근본 원인
리프레시 토큰이 없는 401 분기만 토큰 정리·이동을 하지 않았다.
