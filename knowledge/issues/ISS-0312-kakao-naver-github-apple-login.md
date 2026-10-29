---
type: issue
id: ISS-0312
created: 2026-10-16
topics: [auth-member]
symptoms: [소셜 로그인 준비 중, handleUnavailable, 카카오 로그인, 네이버 로그인, GitHub 로그인, Apple 웹 로그인, 인가 코드 교환]
root_cause: ""
status: open
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/509"
---

# ISS-0312: 카카오, 네이버, GitHub, Apple 로그인 지원

GitHub #509 (원본: 이슈 본문과 댓글). 이슈는 열려 있다(라벨 작업중).

## 증상
- 웹 로그인 화면의 카카오·네이버·GitHub·Apple 버튼이 Google 외에는 "준비 중" 안내만 낸다(`client/src/pages/Login.tsx`의 `handleUnavailable`).
- 서버에는 다섯 가지 로그인 전략이 있지만 클라이언트가 토큰을 받아오는 부분이 없다.
- 카카오·네이버·GitHub 개발자 앱이 등록되지 않아 키가 없다. 앱은 Google과 Apple만 지원한다.
- 같은 이메일의 다른 제공자 계정 처리를 정해야 한다(별도 계정 유지가 기본).

## 재현 조건
웹 로그인 화면에서 Google 외 버튼 클릭 → "준비 중".

## 조사 기록
- 2026-10-17: 서버·웹 구현 보고 — `POST /api/auth/login/code`(인가 코드 교환, 허용 redirect 목록), `GET /api/auth/social-config`(client ID가 비면 준비 중), 분당 20회 제한. 운영 웹에서 네 가지 모두 로그인 확인. 네이버는 "개발 중" 상태라 등록 계정만 로그인 가능(검수요청 필요). 제공자를 바꾸면 별도 계정(계정 연결 없음).
- 2026-10-17: 앱 카카오(`kakao_flutter_sdk_user` 2.0.1)·네이버(`flutter_naver_login` 2.1.1)·GitHub(`flutter_web_auth_2` 5.1.0) 추가, main `59df3f5e`. Android `MainActivity`를 `FlutterFragmentActivity`로. 시뮬레이터에서 끝까지 로그인은 못 함.
- 남은 일(열린 이유): 실기기 로그인 확인, 네이버 검수요청, 탈퇴 시 카카오·네이버 unlink 미구현(GitHub #516에서 다룸), 네이버 Android 플러그인 2.1.1이 client secret을 logcat에 출력(앱에서 막을 수 없음).

## 근본 원인
해당 없음 (기능 추가, 진행 중).
