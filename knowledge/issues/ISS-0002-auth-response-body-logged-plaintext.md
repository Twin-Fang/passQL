---
type: issue
id: ISS-0002
created: 2026-10-07
topics: [security]
symptoms: ["서버 로그 평문", suh-api-log, "응답 본문 로깅", _csrf, "액세스 토큰 로그", "리프레시 토큰 로그", exclude-patterns]
root_cause: "API 로깅(suh-api-log)이 응답 본문 전체를 평문 기록했고, suh-logger.exclude-patterns에는 generate-choices 하나만 제외돼 있었다"
status: resolved
resolution: "[[ISS-0002-auth-response-body-logged-plaintext-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/396"
---

# ISS-0002: 인증 응답 본문(토큰·CSRF)이 서버 로그에 평문으로 기록됨

GitHub #396 (원본: 이슈 본문과 댓글).

## 증상
API 로깅(suh-api-log)이 응답 본문 전체를 평문으로 남긴다. 관리자 로그인 응답의 `_csrf` 토큰이 그대로 기록됨을 확인. 같은 방식이면 `POST /api/auth/login`·`/api/auth/reissue` 응답의 액세스·리프레시 토큰도 로그에 남아, 로그 접근자가 회원 세션을 가로챌 수 있는 구조. 당시 보존 로그에 토큰 문자열은 0건(재시작 이후 로그인 0건이라 노출 여부 자체는 미확인).

## 재현 조건
`curl -s -o /dev/null <API 서버>/admin/login` 후 `docker logs --since 2m passql-back | grep -c 'name="_csrf"'` → 2. 운영 시놀로지, passql-back v0.0.245.

## 조사 기록
- 2026-10-07: `application.yml`의 `suh-logger.exclude-patterns`에 `generate-choices` 하나만 제외돼 있음을 확인.

## 근본 원인
로깅이 응답 본문 전체를 평문으로 남겼고, 제외 패턴에 인증 엔드포인트가 없었다(`generate-choices` 하나만). 라이브러리 기본값 여부는 원본에 없음.
