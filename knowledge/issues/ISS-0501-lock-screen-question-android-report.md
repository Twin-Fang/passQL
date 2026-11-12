---
type: completion-report
id: ISS-0501
created: 2026-11-12
topics: [practice, billing, ads, store-release]
status: resolved
resolves: "[[ISS-0501-lock-screen-question-android]]"
related: ["[[DEC-0290-lock-screen-question-policy]]", "[[ISS-0499-play-fgs-declaration-lock-screen]]"]
source: "https://github.com/Twin-Fang/passQL/issues/990"
---

# ISS-0501 완료 리포트: 잠금화면 위 SQLD 문제 1개, 무료는 크레딧 공유·프로는 한 문제 더

## 해결 방법
- 서버: `LockScreenQuestionService`(스위치 확인 > 선택지 세트 준비된 활성 문제 > 안 푼 문제 우선 1개, 한도 판정은 상세·제출이 기존대로), `GET /api/questions/lockscreen`(꺼짐·후보 없음 204), 운영 설정 3개 `lockscreen.enabled`(기본 false)·`lockscreen.default_interval_minutes`(기본 30)·`lockscreen.include_executable`(기본 true), `AppConfigResponse` 필드, 관리자 카드, API 계약·웹 타입.
- Android 네이티브: `LockScreenService`(포그라운드 서비스, 화면 켜짐 감지), `LockScreenActivity`, 전용 엔진 `LockScreenEngine`, 채널 `passql/lock_screen`, 상태표시줄 알림, `LockScreenBootReceiver`(재부팅 복구).
- 앱: 잠금 위 문제 화면(홈과 같은 크레딧 알약, 제출 시 숫자 내려가는 연출), 소진 화면(하루 1회, 광고 +5 주 버튼·PRO 구매 보조 버튼, 둘 다 잠금 해제 후 앱에서), 권한 단계(필수 3개 + 삼성 절전 예외 권장), 설정 > 학습 토글·간격(매번/30분/1시간/3시간)·문제 유형(전체/객관식만), 소개 시트(몇 문제 뒤 1회, 닫으면 7일 뒤 1번 더), 홈 다음 할 일 카드, 분석 이벤트.
- 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/990#issuecomment-6821643312

## 근본 원인 (확정)
기능 추가. 결함 원인 없음.

## 재발 방지
- 출제 API는 한도를 보지 않고 제출이 기존 하루 한도 판정을 거친다(판정 원본 한 곳).
- 검증: 운영 배포 워크플로우 5개(서버·AI·웹·Play·TestFlight) 성공, 운영 app-config `isLockScreenEnabled=true` 확인. 실기기 검증은 하지 않음.

## 교훈
- 특수 용도 포그라운드 서비스 권한은 Play Console 신고 없이 배포하면 업로드가 거절된다. 현재 배포 앱은 `isLockScreenShipped = false`로 기능을 숨긴 상태라 서버 스위치가 켜져 있어도 보이지 않는다. 다시 켜기는 [[ISS-0499-play-fgs-declaration-lock-screen]].
- 잠금 활동은 `FlutterFragmentActivity`여야 하고(네이버 로그인 플러그인 캐스팅 크래시), 엔진은 캐시 엔진 id로 붙여야 두 번째 표시 때 파괴된 엔진 크래시를 피한다(#1002 후속 3d134f96).
