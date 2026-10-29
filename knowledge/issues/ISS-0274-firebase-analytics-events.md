---
type: issue
id: ISS-0274
created: 2026-10-15
topics: [ops-infra]
symptoms: [분석 도구 없음, 퍼널 측정 불가, firebase_analytics, screen_view, 광고 ID 권한, "com.google.android.gms.permission.AD_ID", Play 업로드 거부]
root_cause: "분석 도구가 없어 가입·풀이·오늘의 세트 완료 같은 퍼널과 잔존율을 측정할 수 없었다"
status: resolved
resolution: "[[ISS-0274-firebase-analytics-events-report]]"
related: ["[[ISS-0272-crashlytics-global-error-handling]]"]
source: "https://github.com/Twin-Fang/passQL/issues/468"
---

# ISS-0274: 앱 퍼널·잔존율 측정 수단 없음 (Firebase Analytics 도입)

GitHub #468 (원본: 이슈 본문과 구현 보고서).

## 증상
분석 도구가 없어 가입, 풀이, 오늘의 세트 완료 같은 퍼널과 잔존율을 측정할 수 없다.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-10-15: 제안 — `firebase_analytics`, GoRouter observer 화면 추적, 핵심 이벤트 5~8개, 이벤트 이름은 상수 파일 한 곳.
- 후속(`ea27bb1`): Analytics가 병합하는 광고 ID 권한(`com.google.android.gms.permission.AD_ID`, `ACCESS_ADSERVICES_*`) 때문에 Play 내부 테스트 업로드가 거부됨(Play Console 선언은 광고 ID 미사용).

## 근본 원인
frontmatter `root_cause`와 같음. Play 업로드 거부는 SDK가 병합한 광고 ID 권한 때문.
