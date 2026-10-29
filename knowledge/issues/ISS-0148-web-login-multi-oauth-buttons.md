---
type: issue
id: ISS-0148
created: 2026-04-22
topics: [auth-member]
symptoms: ["Google 로그인 버튼만", Login.tsx, "Kakao Naver 버튼 없음", OAuthCallback, AuthProvider]
root_cause: "백엔드는 provider 5개를 지원하나 웹 로그인 UI는 Google 버튼만 노출"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/274"
---

# ISS-0148: 웹 로그인 페이지에 Google 외 OAuth 버튼이 없음

GitHub #274 (원본: 이슈 본문과 댓글). 라벨 `취소`.

취소로 닫힘: 2026-10-07 댓글 — "웹 로그인 페이지의 Kakao/Naver/GitHub 버튼은 2026-04 시점의 웹 중심 기획이라 현재 서비스(Flutter 앱 + 데일리 세트 중심 학습 흐름)와 맞지 않는 오래된 명세로 보고 취소한다. 필요하면 현재 기준으로 새 이슈를 만든다. 현재 로그인은 앱의 Google/Apple 중심이다."

## 증상
`client/src/pages/Login.tsx`에 Google 버튼만 있다. `client/src/api/auth.ts`의 `AuthProvider`는 `GOOGLE | KAKAO | NAVER | APPLE | GITHUB`를 선언하고 백엔드 `AuthController`도 5개 전략을 지원한다. Kakao/Naver는 Firebase가 아닌 REST API 검증이라 프론트의 토큰 획득 방식이 Google(Firebase popup)과 다르다.

## 재현 조건
웹 로그인 페이지 진입.

## 조사 기록
- 2026-04-22: 제안 — Kakao·Naver(redirect, `client/src/pages/OAuthCallback.tsx`, `/oauth/callback` 라우트), Apple(`OAuthProvider('apple.com')`) 버튼. 기존 localStorage 익명 데이터는 마이그레이션하지 않고 삭제.
- 2026-04-25 댓글: "Google 추가 완료".
- 2026-10-07 댓글: 취소(위 사유).

## 근본 원인
해당 없음 (취소).
