---
type: issue
id: ISS-0518
created: 2026-11-14
topics: [auth-member, security, practice]
symptoms: ["잠금화면 401", "reissue INVALID_TOKEN", "refresh token reuse detected", "모든 기기 로그아웃", "잠금화면 not signed in", "dismissed quietly", "TokenStore 캐시", "두 Flutter 엔진", "앱 다시 켜면 로그인 화면"]
root_cause: "Android 잠금화면 엔진과 앱 엔진이 같은 보안 저장소를 쓰면서 세션을 엔진별 메모리에 캐시해, 한쪽이 회전한 refreshToken 을 다른 쪽이 옛 값으로 재사용(서버가 전체 세션 폐기)하고 공용 저장소까지 지웠다"
status: resolved
resolution: "[[ISS-0518-lock-screen-engine-stale-refresh-token-reuse-report]]"
related: ["[[ISS-0517-lock-screen-free-pro-explanation-continue]]", "[[DEC-0314-lock-screen-free-reason-pro-detail-continue]]"]
source: "_sources/issues/ISS-0518-lock-screen-engine-stale-refresh-token-reuse.md"
---

# ISS-0518: 잠금화면 엔진이 옛 refreshToken 으로 재발급해 모든 기기 로그아웃될 수 있음

GitHub #1071. 원본: https://github.com/Twin-Fang/passQL/issues/1071 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1071#issuecomment-6873630543

## 증상
- 앱이 토큰을 재발급한 뒤 화면을 켜면 잠금화면이 `/auth/reissue` 401 `INVALID_TOKEN` 으로 조용히 닫히고, 앱을 다시 켜면 로그인 화면.
- 서버 `[auth] refresh token reuse detected` > 같은 계정의 모든 기기 로그아웃.
- 앱에서 다시 로그인해도 잠금화면은 "not signed in" 으로 닫힘(잠금 엔진이 시작 때 읽은 로그아웃 상태 유지).

## 재현 조건
Android, 잠금화면 문제 켜짐. 잠금 엔진이 떠 있는 동안 앱 엔진이 액세스 토큰 만료로 재발급(1시간 이상 지난 뒤 앱 사용) > 화면 켜기.

## 조사 기록
- 2026-11-14: #1068 PRO 화면 확인 중 에뮬레이터 logcat 에서 앱 16:00:15 재발급 성공 > 잠금 16:00:43 옛 토큰 재발급 401 > `tokenStore.clear()` 확인. 서버 `AuthService.revokeAllSessionsIfReused`.
