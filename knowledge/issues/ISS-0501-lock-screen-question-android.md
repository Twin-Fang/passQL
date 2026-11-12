---
type: issue
id: ISS-0501
created: 2026-11-12
topics: [practice, billing, ads, store-release]
symptoms: ["잠금화면 문제", "LockScreenService", "LockScreenActivity", "isLockScreenShipped", "GET /api/questions/lockscreen", "lockscreen.enabled", "잠금화면 소개 시트 안 뜸", "다른 앱 위에 표시 권한", "배터리 최적화 제외"]
root_cause: "문제를 풀려면 앱을 직접 켜야 해서 하루 여러 번 마주칠 접점이 없었다 (기능 추가)"
status: resolved
resolution: "[[ISS-0501-lock-screen-question-android-report]]"
related: ["[[DEC-0290-lock-screen-question-policy]]", "[[ISS-0499-play-fgs-declaration-lock-screen]]"]
source: "https://github.com/Twin-Fang/passQL/issues/990"
---

# ISS-0501: 잠금화면 문제 풀기 (Android)

GitHub #990. 원본 사본: `_sources/issues/ISS-0501-lock-screen-question-android.md`(로컬).

## 증상
- 문제를 풀려면 앱을 직접 켜야 해서 하루 학습이 앱을 여는 날에만 일어난다.
- SQLD는 짧게 자주 반복하는 게 핵심인데 하루 여러 번 마주칠 접점이 없다.
- 무료 사용자가 프로를 체감할 입구도 앱 안에만 있다.

## 재현 조건
기능 추가 이슈. Android 전용(iOS는 잠금 위 오버레이 불가로 범위 밖).

## 조사 기록
- 2026-11-12: fe222df0(서버 출제 API·운영 설정 3개·관리자 카드, Android 포그라운드 서비스·잠금 위 화면, 앱 소개 시트·권한 단계·설정 행), edaa820f(코드 점검 반영), 7113cae3(개발자 도구), e262e3ab(온보딩 AI 해설 슬라이드), 643361b3(NEW 배지 제거), d00454c5(보상 창 위에서 소개 시트 안 뜨던 문제). PR #994, #996, #1009, 배포 PR #1012.
- 2026-11-12: Play 업로드가 포그라운드 서비스 권한 미신고로 거절 > 앱에서 기능을 숨김(`isLockScreenShipped = false`) — [[ISS-0499-play-fgs-declaration-lock-screen]](#1002, 열림).

## 근본 원인
기능 추가 이슈라 결함 원인은 없음. 접점이 앱 안에만 있던 구조.
