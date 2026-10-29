---
type: issue
id: ISS-0147
created: 2026-04-18
topics: [auth-member, ci-deploy]
symptoms: ["Firebase 초기화 실패", FIREBASE_SERVICE_ACCOUNT_PROD_JSON, APPLICATION_PROD_YML, firebase-service-account-dev.json, "dev 서버 기동 불가", "jwt 설정 블록 없음"]
root_cause: "OAuth + JWT 코드는 구현됐으나 Firebase 서비스 계정 JSON 미발급, Secret·설정 미등록"
status: resolved
resolution: "[[ISS-0147-firebase-project-and-secrets-report]]"
related: ["[[DEC-0080-firebase-oauth-own-jwt-no-anonymous]]"]
source: "https://github.com/Twin-Fang/passQL/issues/272"
---

# ISS-0147: Firebase 서비스 계정·Secret 미등록으로 서버 기동 실패

GitHub #272 (원본: 이슈 본문과 댓글). GitHub #271 후속.

## 증상
- Firebase 서비스 계정 JSON 미발급.
- `FIREBASE_SERVICE_ACCOUNT_PROD_JSON` GitHub Secret 미등록 → prod 배포 시 Firebase 초기화 실패.
- `APPLICATION_PROD_YML` Secret에 `jwt`, `firebase` 블록 없음 → prod 기동 오류.
- 로컬 `firebase-service-account-dev.json` 없음 → dev 서버 기동 불가.

## 재현 조건
Secret·파일 없이 dev/prod 서버 기동.

## 조사 기록
- 2026-04-18: 작업 목록 — Firebase 프로젝트 생성(`passql`), Sign-in method Google·Apple·Github 활성화, 카카오·네이버 앱 등록, 서비스 계정 키 발급 후 `server/PQL-Web/src/main/resources/firebase-service-account-dev.json`(로컬)과 Secret 등록, `openssl rand -base64 64`로 JWT secret 2개, `APPLICATION_PROD_YML`에 `jwt.access`(expiration `1h`)·`jwt.refresh`(expiration `14d`)·`firebase.key-path` 추가, dev 기동 확인(`POST /api/auth/login` 빈 body → validation 에러), prod Firebase 초기화 로그 확인. 체크박스는 모두 미체크 상태로 남아 있다.

## 근본 원인
외부 콘솔 설정과 Secret 등록이 남아 있었다.
