---
type: completion-report
id: ISS-0172
created: 2026-10-07
topics: [auth-member, security]
status: resolved
resolves: "[[ISS-0172-app-server-jwt-google-apple-login]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/327"
---

# ISS-0172 완료 리포트: 앱 Google/Apple 로그인 → 서버 JWT, 재발급 인터셉터, 로그아웃

GitHub #327 진행 댓글(2026-10-02 두 건)과 완료 댓글(2026-10-07) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
- 1차(커밋 `6ffb2a1`): 토큰 보안 저장(secure storage), 인증 API(`/auth/login`, `/auth/reissue`, `/auth/logout`). 401 자동 재발급 인터셉터 — 동시 401은 재발급 1회로 합침, 재발급 실패 시 로그아웃, 재시도 1회 제한. 로그인 화면(Google, iOS는 Apple 버튼)과 라우터 가드. 앱 ID `com.example.*` → `kr.suhsaechan.passql`(Android, iOS), 표시 이름 `passQL`. core library desugaring 활성화로 안드로이드 빌드 차단 해소.
- Firebase 연결(커밋 `26f1125`): 서버와 같은 Firebase 프로젝트 `passql`에 Android·iOS 앱 등록, 디버그 서명 SHA-1 등록. Google/Apple 로그인으로 Firebase ID 토큰을 받아 서버 `/auth/login`에 전달(Apple은 일회용 nonce). 취소 시 오류 없이 로그인 화면 유지. 설정 화면 로그아웃(서버 토큰 폐기, 세션·소셜 상태 삭제). 계정 전환 시 홈·통계·설정·순위 캐시 초기화, 닉네임은 로그인 세션 기준. Android 구글 서비스 Gradle 플러그인, 코틀린 2.2.20, iOS 최소 15, URL 스킴, Sign in with Apple 권한 파일.
- `google-services.json`, `GoogleService-Info.plist`는 "환경별 값이라" 커밋하지 않고 `.gitignore`, 받는 방법은 `app/docs/FIREBASE-SETUP.md`.
- 검증: 2026-10-07 `flutter analyze` 무이슈, 테스트 147개 통과, 실계정 E2E와 TestFlight/Play 비공개 테스트 빌드 확인. 진행 기록 GitHub #347, #348.

원본 댓글의 Firebase 앱 식별자 값은 노트에 옮기지 않았다.

## 근본 원인 (확정)
앱이 서버 JWT 인증 이전 방식(UUID 헤더·쿼리)을 쓰고 있었다.

## 재발 방지
- macOS/Linux/Windows 타깃의 `com.example` 식별자는 모바일 출시와 무관해 유지(원본).
- 릴리스 빌드가 debug 키로 서명됨 → 출시 전 서명 설정, 릴리스 키스토어 SHA-1 등록과 `google-services.json` 재발급 필요(GitHub #339로 이관).

## 교훈
(원본에 없음, 볼트 정리) 앱 로그인 뒤 다른 계정 데이터가 보이면 계정 전환 시 사용자별 캐시 초기화부터 본다.
