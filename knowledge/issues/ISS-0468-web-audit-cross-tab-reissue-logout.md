---
type: issue
id: ISS-0468
created: 2026-11-07
topics: [auth-member, security, practice, dev-workflow]
symptoms: ["웹 탭 두 개 모든 기기 로그아웃", "옛 refresh token 재사용 탐지", "재발급 실패 강제 로그아웃", "네트워크 오류 로그아웃", "5xx 로그아웃", "선택지 생성 SSE 4xx errorCode 버림", "한도 사유 없이 실패 화면", "닉네임 변경 대기 기간 불일치", "약관 원본 두 곳", "siteUrls.test.ts 삭제", "손으로 복사한 API 타입", "옛 번들 로드 실패", authStore.ts, api/client.ts, AuthService, questions.ts, ChoiceGenerationStatus.tsx, ExamTrend.tsx]
root_cause: "웹 탭마다 따로 재발급해 이미 회전된 refresh token 을 다시 보냈고(서버 재사용 탐지가 전 기기 세션 폐기), 재발급 실패를 종류 구분 없이 로그아웃으로 처리했다"
status: resolved
resolution: "[[ISS-0468-web-audit-cross-tab-reissue-logout-report]]"
related: ["[[DEC-0269-web-reissue-single-across-tabs]]", "[[DEC-0270-reissue-logout-only-on-session-end]]", "[[DEC-0144-per-device-refresh-token-reuse-revoke]]", "[[ISS-0316-social-login-token-unlink-account-switch]]", "[[ISS-0462-web-wrong-notes-page-404]]", "[[DEC-0105-legal-docs-single-source-server-db]]", "[[DEC-0119-legal-urls-on-github-pages]]", "[[ISS-0467-server-audit-llm-limit-osiv-choice-set-cache]]"]
source: "_sources/issues/ISS-0468-web-audit-cross-tab-reissue-logout.md"
---

# ISS-0468: 웹 전체 점검 수정 — 탭 두 개면 모든 기기 로그아웃, 재발급 실패 강제 로그아웃, 선택지 생성 오류 사유

GitHub #881 (https://github.com/Twin-Fang/passQL/issues/881). 2026-11-07 웹·스택 간 점검에서 원본을 열어 확인. 연습 제출 실패·프로 잠금 무반응은 #865([[ISS-0462-web-wrong-notes-page-404]])에서 함께 처리.

## 증상
- (high) 웹 탭을 두 개 열면 한 탭의 토큰 재발급 뒤 다른 탭이 옛 refresh token 을 보내고, 서버가 재사용(탈취)으로 판단해 앱을 포함한 모든 기기 세션을 지움 (`authStore.ts`, `api/client.ts` <-> 서버 `AuthService`, [[DEC-0144-per-device-refresh-token-reuse-revoke]]).
- (med) 재발급이 네트워크 오류·타임아웃·5xx 여도 강제 로그아웃 (`api/client.ts`).
- (med) 선택지 생성(SSE) 4xx 응답의 `errorCode` 를 버려 한도·잠금 사유 없이 실패 화면 (`questions.ts`, `ChoiceGenerationStatus.tsx`).
- (med) 닉네임 변경 대기 기간 계산이 웹(자정 + 2일)과 서버(72시간)에서 다름.
- (med) 약관 원본이 DB 와 GitHub Pages 두 곳 — [[DEC-0105-legal-docs-single-source-server-db]] <-> [[DEC-0119-legal-urls-on-github-pages]] 충돌, 결정 필요.
- (med) 지워진 `siteUrls.test.ts` 를 "검사 중"이라 적은 주석, 운영 주소 사본 약 20곳 무검사.
- (low-med) 손으로 복사한 API 타입·enum, `ExamTrend.tsx` 회차 각주 고정, 죽은 페이지, canonical 순환, 배포 직후 옛 번들 로드 실패 시 자동 새로고침 없음.

## 재현 조건
같은 브라우저에서 웹 탭 두 개로 로그인 상태를 유지 > 한 탭에서 토큰 재발급 > 다른 탭에서 access token 만료 > 앱 포함 모든 기기 로그아웃.

## 조사 기록
- 2026-11-07: 웹·스택 간 점검(내부, 이전 감사 2026-11-02 후속)에서 발견, 같은 날 PR #893 으로 수정.

## 근본 원인
웹 재발급이 탭 안에서만 한 번으로 묶여 있고 탭 사이에는 조율·토큰 동기화가 없었다. 재발급 실패 처리는 일시 오류와 세션 종료를 구분하지 않았다.
