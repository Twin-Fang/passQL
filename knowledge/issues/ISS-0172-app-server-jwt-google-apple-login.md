---
type: issue
id: ISS-0172
created: 2026-10-02
topics: [auth-member, security]
symptoms: ["앱 401", X-Member-UUID, "memberUuid 쿼리", "/members/register", "/api/auth/login", "/api/auth/reissue", "Sign in with Apple", "core library desugaring"]
root_cause: "서버는 `Authorization: Bearer` JWT만 인증으로 인정하는데 앱은 `X-Member-UUID` 헤더·`memberUuid` 쿼리·없는 `/members/register`를 사용"
status: resolved
resolution: "[[ISS-0172-app-server-jwt-google-apple-login-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/327"
---

# ISS-0172: 앱 서버 JWT 인증 전환 (Google/Apple 로그인)

GitHub #327 (원본: 이슈 본문과 진행 댓글 3개). 관련 GitHub #271(서버/웹 OAuth·JWT 구현).

## 증상
(현재 문제점) 서버는 `Authorization: Bearer` JWT만 인증으로 인정하고 공개 경로는 `/api/auth/**`와 `GET /api/meta/**`뿐이다. 앱은 `X-Member-UUID` 헤더, `memberUuid` 쿼리, 서버에 없는 `/members/register`를 써서 인증이 필요한 API가 모두 401이 될 것으로 예상됐다.

## 재현 조건
해당 없음 (앱 전체 인증 구조).

## 조사 기록
- 2026-10-02 제안: Google 로그인 → 서버 `/api/auth/login` 토큰 발급, iOS는 Sign in with Apple 함께 검토, 보안 저장소 보관, 401 시 `/api/auth/reissue` 공통 처리, 기존 UUID 회원 처리 정책 결정.
- 2026-10-02 1차 구현(커밋 `6ffb2a1`): 이 과정에서 안드로이드 디버그 빌드 실패 원인이 core library desugaring 비활성이었음을 찾아 수정.
- 2026-10-02 Firebase 연결(커밋 `26f1125`).
- 2026-10-07 실계정 E2E 확인.
- 기존 UUID 회원 처리 정책은 원본 댓글에 결론이 적혀 있지 않다.

## 근본 원인
앱 API 정의가 서버의 JWT 전환 이전 방식에 머물러 있었다.
