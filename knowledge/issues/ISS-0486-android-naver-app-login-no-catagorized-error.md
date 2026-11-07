---
type: issue
id: ISS-0486
created: 2026-11-07
topics: [auth-member]
symptoms: ["no_catagorized_error", "Android 네이버 로그인 실패", "네이버 앱 설치 기기", "앱 간 로그인", "서버에 로그인 요청 없음", "NaverIdLoginSDK.behavior", NidOAuthBehavior, flutter_naver_login, naver_social_sign_in.dart]
root_cause: ""
status: open
resolution: null
related: ["[[ISS-0329-android-naver-login-device-check]]", "[[ISS-0316-social-login-token-unlink-account-switch]]", "[[ISS-0312-kakao-naver-github-apple-login]]"]
source: "_sources/issues/ISS-0486-android-naver-app-login-no-catagorized-error.md"
---

# ISS-0486: Android 네이버 앱 설치 기기에서 네이버 로그인 실패 (no_catagorized_error)

GitHub #942 (https://github.com/Twin-Fang/passQL/issues/942). 열림: 수정 빌드 실기기 확인 대기.

## 증상
- 실기기(Galaxy SM-F766N, Android 17, 앱 1.94.0(510), 의견 보내기 로그): 네이버로 계속하기 3번 모두 1초 안팎에 `[naver login] failed : status error, error errorCode:no_catagorized_error, errorDesc:no_catagorized_error`.
- 서버 로그에 네이버 로그인 요청 없음 (SDK 단계에서 실패).

## 재현 조건
네이버 앱이 깔린 Android 기기 (추정). 같은 계정이 운영 웹, 네이버 앱 없는 Android 에뮬레이터(Chrome 로그인 화면 경로)에서는 로그인됨.

## 조사 기록
- 2026-11-07: 네이버 개발자 콘솔 확인: 개발 상태 서비스 적용, Android 패키지 `com.coldredrice.passql`, 다운로드 URL, Client ID·Secret 이 앱 `.env` 와 일치(해시 비교). 콘솔 설정 문제 아님.
- 2026-11-07: 앱 네이버 로그인 코드·Android 매니페스트 최근 변경 없음. 에뮬레이터(API 36.1)에 네이버 앱을 깔아 재현하려 했으나 저장 공간 부족.
- 2026-11-07: 수정: 네이버 앱 로그인이 실패(취소 아님)하면 `NaverIdLoginSDK.behavior = CUSTOMTABS` 로 바꿔 1회 재시도, 다음 로그인은 다시 DEFAULT (MainActivity 채널 `passql/naver_login_behavior`, SDK 5.10.0, 7c331a3f). 에뮬레이터 기존 경로 정상, 재시도 판정 테스트 2개. 테스트 APK 1.94.1(89976186) 실기기 확인 대기.
- 예전에 Android 네이버 로그인 실기기 복귀는 확인되지 않은 채 정리됐다: [[ISS-0329-android-naver-login-device-check]] (#516 taskAffinity 수정 뒤).

## 근본 원인
미확정. 추정: 네이버 앱이 깔린 기기에서 SDK 가 쓰는 네이버 앱 로그인(앱 간 전환) 경로가 그 기기에서 실패.
