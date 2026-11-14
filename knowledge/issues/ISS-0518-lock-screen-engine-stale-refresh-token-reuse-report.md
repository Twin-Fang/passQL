---
type: completion-report
id: ISS-0518
created: 2026-11-14
topics: [auth-member, security, practice]
status: resolved
resolves: "[[ISS-0518-lock-screen-engine-stale-refresh-token-reuse]]"
related: ["[[ISS-0517-lock-screen-free-pro-explanation-continue]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1071#issuecomment-6873630543"
---

# ISS-0518 완료 리포트: 401·재발급 판단을 저장소 기준으로

## 해결 방법
- `TokenStore.reload()` 로 캐시를 버리고 저장소에서 다시 읽기.
- `AuthInterceptor`: 401 판단과 재발급 직전에 저장소를 다시 읽어, 다른 엔진이 이미 갱신했으면 재발급 없이 재시도. 재발급 거절 시 그 사이 저장소 토큰이 바뀌었으면 세션 유지.
- `AuthNotifier.reloadFromStorage()`: 잠금화면 표시 때 로그인 상태를 저장소에서 다시 읽음.
- 판정 테스트 `auth_interceptor_shared_storage_test.dart`. PR #1072, 커밋 9e8cebeb.

## 근본 원인 (확정)
엔진별 메모리 캐시가 저장소와 어긋났고, 서버는 회전된 refreshToken 재사용을 탈취로 보고 전체 세션을 폐기한다.

## 재발 방지
- 토큰·로그인 상태처럼 엔진이 공유하는 값은 판단 직전에 저장소에서 다시 읽는다.
- 남은 위험: 두 엔진이 1초 안에 동시에 재발급하면 한쪽이 거절될 수 있다(엔진 사이 잠금이나 서버 유예 시간 필요).

## 교훈
- Android 잠금화면처럼 두 번째 Flutter 엔진을 띄우면 메모리 캐시(세션·설정)는 엔진마다 따로다. 공유 저장소 값은 쓰기 전에 다시 읽는다.
