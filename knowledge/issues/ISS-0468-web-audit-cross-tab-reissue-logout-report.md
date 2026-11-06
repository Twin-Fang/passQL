---
type: completion-report
id: ISS-0468
created: 2026-11-07
topics: [auth-member, security, practice, dev-workflow]
status: resolved
resolves: "[[ISS-0468-web-audit-cross-tab-reissue-logout]]"
related: ["[[DEC-0269-web-reissue-single-across-tabs]]", "[[DEC-0270-reissue-logout-only-on-session-end]]", "[[DEC-0144-per-device-refresh-token-reuse-revoke]]"]
source: "_sources/issues/ISS-0468-web-audit-cross-tab-reissue-logout-report.md"
---

# ISS-0468 완료 리포트: 탭 간 재발급 한 번(Web Locks)·토큰 동기화, 세션 종료일 때만 로그아웃, 선택지 생성 오류 사유 표시

GitHub #881 리포트 기준 (2026-11-07). PR #893 머지, 릴리스 #896 으로 운영 배포.

## 해결 방법
- 인증:
  - 탭 간 토큰 동기화: `storage` 이벤트로 다른 탭의 새 토큰을 바로 반영 (`authStore.ts`).
  - 재발급 단일 실행: Web Locks 로 여러 탭 중 한 탭만 재발급, 잠금 안에서 저장값을 다시 읽어 이미 회전된 refresh token 을 재사용하지 않음 (`accessTokenReissueCoordinator.ts`, 핵심 판정 단위 테스트) — [[DEC-0269-web-reissue-single-across-tabs]].
  - 강제 로그아웃은 재발급 401 또는 회원 없음(`MEMBER_NOT_FOUND`)일 때만, 네트워크 오류·타임아웃·5xx 는 세션 유지 (`api/client.ts`) — [[DEC-0270-reissue-logout-only-on-session-end]].
- 오류 사유 표시:
  - 선택지 생성(SSE) 시작 전 거부의 `errorCode` 유지 > 하루 한도·프로 필요는 사유 본문, 그 외는 서버 문구 + 다시 시도 (`choiceGenerationError.ts`, `ChoiceGenerationStatus.tsx`).
  - 닉네임 변경 대기: 서버 값 `nicknameChangeAvailableAt` 하나로 통일, 서버 응답·계약 갱신.
- 단일 원본·정리: 손으로 복사한 인증·신고·약관 타입 > 생성 타입(`openapi.ts`) 별칭. `siteUrls.test.ts` 복원(iOS 마케팅 URL, 서버 소셜 콜백, CORS 포함). 디자인 토큰 규칙 테스트 복원(`ring-offset`·`outline-offset` 굵기 클래스를 색으로 오인하던 것 수정). 출제 경향 고정 회차 각주 제거, boolean 이름 정리. 배포 직후 옛 번들 로드 실패 시 한 번 자동 새로고침 (`staleBundleReload.ts`).

## 검증
- 웹 `npm run lint`, `npm test`, `tsc --noEmit`, 서버 계약 테스트, CI 통과.
- 운영 API 실측: 필수값 빠진 재발급 요청 > 400 `VALIDATION_ERROR` (웹은 401·회원 없음에서만 로그아웃하므로 세션 유지 경로).

## 근본 원인 (확정)
탭 사이에 재발급 조율·토큰 동기화가 없어 회전된 refresh token 이 재사용됐고, 서버 재사용 탐지([[DEC-0144-per-device-refresh-token-reuse-revoke]])가 전 기기 세션을 폐기했다. 재발급 실패 처리가 일시 오류와 세션 종료를 구분하지 않았다.

## 재발 방지
- 재발급 경로를 고칠 때 잠금 안에서 저장값을 다시 확인하는 단계를 빼지 않는다 — 빼면 탭 두 개 문제가 돌아온다.
- API 타입은 `npm run gen:api` 생성 타입만 쓴다.

## 남은 일
- 약관 원본 이중화([[DEC-0105-legal-docs-single-source-server-db]] <-> [[DEC-0119-legal-urls-on-github-pages]] 충돌)는 사용자 결정이 필요하며 이 이슈에서 고치지 않았다.

## 교훈
서버가 refresh token 재사용을 탈취로 보고 전 기기를 끊는다면, 클라이언트는 같은 기기 안의 모든 실행 단위(탭)를 통틀어 재발급을 한 번만 보내야 한다. "요청 단위 한 번"이 아니라 "저장소 단위 한 번"이다.
