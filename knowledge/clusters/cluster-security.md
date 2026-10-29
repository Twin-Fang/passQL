---
type: cluster
topic: security
created: 2026-10-29
members: 43
status: active
related: []
---

# 클러스터: security

## 이 주제는
인증 토큰·CSRF·민감 정보 노출 등 보안 결함과 대책.

## 현재 상태 요약
(2026-10-29) 관리자 CSRF 헤더는 공통 fetch 래퍼가 붙인다 — [[DEC-0008-admin-csrf-common-fetch-wrapper]]. 인증 엔드포인트 본문은 서버 로그에 남기지 않는다([[ISS-0002-auth-response-body-logged-plaintext]]).

## 활성 결정
- [[DEC-0008-admin-csrf-common-fetch-wrapper]] — 관리자 CSRF 헤더는 화면별이 아니라 `layout.html` 공통 fetch 래퍼에서 붙인다
- [[DEC-0080-firebase-oauth-own-jwt-no-anonymous]] — 소셜 로그인 토큰을 서버가 검증해 자체 JWT(AT 1h + RT 14d, Redis)를 발급하고, 익명 회원은 없앤다
- [[DEC-0086-permit-async-dispatch-in-security]] — Spring Security에서 `DispatcherType.ASYNC`는 인증 재검사 없이 `permitAll()`
- [[DEC-0097-release-signing-key-properties]] — Android 릴리스 서명은 `key.properties` 기반, 키스토어·비밀번호는 저장소 밖(로컬·CI 시크릿)
- [[DEC-0102-fixed-error-messages-detail-in-logs]] — API 오류 메시지는 고정 문구만 내보내고 상세는 서버 로그에만 남긴다
- [[DEC-0103-cors-service-domain-allowlist]] — API CORS 허용 Origin은 서비스 도메인만, `cors.allowed-origin-patterns` 설정으로 관리
- [[DEC-0106-unified-error-body-for-security-errors]] — 401·403·404도 `{"errorCode","message"}`로 통일하고 인증 실패·접근 거부는 WARN 로그
- [[DEC-0107-sensitive-key-suffix-match]] — 설정 키 민감 판정은 `. _ -`로 나눈 조각이 민감 단어로 끝날 때만
- [[DEC-0117-secret-files-nas-backup]] — GitHub Secret 파일은 main push마다 시놀로지에 백업하고, 새 키는 로컬·Secret·백업 블록을 한 번에 등록한다
- [[DEC-0126-suspended-member-common-filter]] — 제재 회원 차단은 JWT 인증 뒤 공통 필터 한 곳에서, 인증·메타·탈퇴 요청은 예외
- [[DEC-0130-admin-accounts-roles-lockout-rate-limit]] — 관리자 계정은 `admin_account` 테이블(ADMIN/VIEWER), yml 기본 계정은 시드·폴백으로 유지, 로그인 잠금과 인메모리 요청 제한
- [[DEC-0138-solving-detail-hides-answers]] — 사용자용 문제 상세는 응답 형태를 유지한 채 정답 필드를 비우고 최신 OK 세트 1개만 보낸다
- [[DEC-0142-encrypt-sqld-research-materials]] — 출제 경향 조사 원문은 로컬에만 두고 레포에는 AES-256 암호본만 커밋한다
- [[DEC-0143-server-side-social-unlink-on-withdraw]] — 탈퇴 시 소셜 제공자 연결 해제는 서버가 하고, GitHub·네이버 토큰은 암호화 보관한다
- [[DEC-0144-per-device-refresh-token-reuse-revoke]] — refresh token은 기기별(`jti`)로 저장하고, 이미 회전된 토큰이 다시 오면 그 회원 세션을 전부 폐기한다
- [[DEC-0214-no-local-design-docs-in-public-vault]] — 퍼블릭 레포 볼트에는 로컬 전용 설계 문서를 넣지 않고, 서버 경로·호스트·내부 포트를 쓰지 않는다

## 대체된 결정 (역사)
- [[DEC-0026-sensitive-settings-masked-readonly]] → DEC-0107
- [[DEC-0032-gemini-key-runtime-from-settings]] → DEC-0133
- [[DEC-0081-admin-session-chain-yml-account]] → DEC-0130
- [[DEC-0133-encrypted-gemini-key-single-source]] → DEC-0188

## 관련 이슈
- [[ISS-0386-admin-account-management]] (open, GitHub #631) — 관리자 계정 삭제·활동 이력 바로가기·세션 강제 종료·2FA·비밀번호 만료 정책이 없음
- [[ISS-0001-admin-fetch-csrf-header-missing]] (resolved, GitHub #391) — 관리자 화면 fetch 요청에 CSRF 헤더가 없어 상태 변경이 403으로 실패
- [[ISS-0002-auth-response-body-logged-plaintext]] (resolved, GitHub #396) — 인증 응답 본문(토큰·CSRF)이 서버 로그에 평문으로 기록됨
- [[ISS-0033-gemini-key-dynamic-db-redis]] (resolved, GitHub #47) — Gemini API Key를 DB·Redis에서 동적 관리
- [[ISS-0146-oauth-jwt-auth-system]] (resolved, GitHub #271) — 서버에 인증이 전혀 없고 익명 가입만 가능
- [[ISS-0149-admin-form-login-session-chain]] (resolved, GitHub #275) — Thymeleaf 관리자 페이지에 누구나 인증 없이 접근 가능
- [[ISS-0166-sse-async-dispatch-access-denied]] (resolved, GitHub #310) — SSE async dispatch에서 Spring Security Access Denied로 선택지 생성 실패
- [[ISS-0172-app-server-jwt-google-apple-login]] (resolved, GitHub #327) — 앱 서버 JWT 인증 전환 (Google/Apple 로그인)
- [[ISS-0187-daily-set-score-client-trusted]] (resolved, GitHub #342) — 데일리 세트 리더보드 점수를 클라이언트 값 그대로 저장해 조작 가능
- [[ISS-0224-https-forward-headers-secure-cookie]] (resolved, GitHub #389) — HTTPS 전환 누락으로 관리자 로그인이 평문 제공되고 세션 쿠키에 `Secure`가 없음
- [[ISS-0225-legacy-quiz-unauthenticated]] (resolved, GitHub #390) — `/quiz` 레거시 화면이 인증 없이 열려 있음
- [[ISS-0227-unsupported-media-type-500-signature-leak]] (resolved, GitHub #393) — 미지원 Content-Type이 500으로 응답되고 오류 메시지에 내부 시그니처 노출
- [[ISS-0228-cors-wildcard-origin-reflection]] (resolved, GitHub #394) — CORS가 모든 Origin을 반사함 — 서비스 도메인으로 제한
- [[ISS-0239-api-error-format-and-auth-failure-logs]] (resolved, GitHub #406) — API 에러 응답 형식이 세 가지로 섞여 있고 인증 실패가 로그에 남지 않음
- [[ISS-0240-max-tokens-misclassified-sensitive]] (resolved, GitHub #408) — 앱 설정 `ai.default_max_tokens`가 민감 키로 오인돼 값이 가려지고 수정 불가
- [[ISS-0250-admin-monitor-server-errors-swagger-lock]] (resolved, GitHub #440) — 관리자 모니터링에 서버 오류 없음, 운영 Swagger 무인증 공개, 요청 요약 상태 오기록
- [[ISS-0258-github-secret-synology-backup]] (resolved, GitHub #452) — GitHub Secret 파일의 원본 백업이 없어 잃으면 복구 불가
- [[ISS-0276-suspended-member-blocked-only-in-getme]] (resolved, GitHub #470) — 제재 회원 차단이 getMe에서만 동작
- [[ISS-0284-admin-accounts-roles-lockout-rate-limit]] (resolved, GitHub #478) — 관리자 계정이 yml 단일 계정뿐이고 로그인 잠금·요청 제한이 없음
- [[ISS-0298-gemini-key-single-source-encrypted]] (resolved, GitHub #492) — Gemini API 키 원본이 두 곳이고 DB·Redis에 평문 저장
- [[ISS-0308-question-api-exposes-answers]] (resolved, GitHub #503) — 문제 조회 API가 정답, 해설, 정답 SQL을 사용자에게 노출
- [[ISS-0316-social-login-token-unlink-account-switch]] (resolved, GitHub #516) — 소셜 로그인 토큰 검증 강화, 탈퇴 연결 해제, 계정 전환 시 이전 회원 데이터 노출
- [[ISS-0378-admin-audit-log-search-access-events]] (resolved, GitHub #623) — 관리자 감사 로그에 동작 필터·검색이 없고 접근 이벤트가 기록되지 않는 것으로 보임
