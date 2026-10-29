---
type: issue
id: ISS-0315
created: 2026-10-17
topics: [ci-deploy]
symptoms: [Firebase App Distribution, 테스터 빌드 미배포, PLAY_ACCOUNT_NOT_LINKED, FIREBASE_APP_ID 템플릿 값, PROJECT-FLUTTER-ANDROID-FIREBASE-CICD]
root_cause: "Firebase 워크플로는 push 트리거가 꺼지고 앱 ID가 템플릿 값이었으며, 실제 배포 경로인 Play Store 워크플로에는 Firebase 단계가 없었다"
status: resolved
resolution: "[[ISS-0315-firebase-distribution-not-deployed-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/513"
---

# ISS-0315: 스토어 배포 시 Firebase App Distribution 테스터에게 빌드가 배포되지 않음

GitHub #513 (원본: 이슈 본문과 댓글).

## 증상
스토어 배포(Play 내부 테스트)를 해도 Firebase App Distribution 테스터에게 새 빌드가 가지 않는다. Firebase 릴리스는 10-16 수동 TEST-APK 실행으로 올라간 1.2.1 하나뿐이다.

## 재현 조건
`PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`로 스토어 배포 실행 → Firebase 릴리스 없음.

## 조사 기록
- 2026-10-17: 원인 확인 후 `8c47304b`로 수정, run 39038164337에서 Firebase job 성공.

## 근본 원인
`PROJECT-FLUTTER-ANDROID-FIREBASE-CICD.yaml`은 push 트리거가 꺼져 있고(`cbbc013c`) `FIREBASE_APP_ID`가 템플릿 값(`your-firebase-app-id`) 그대로이며 모노레포 경로를 모른다. 실제 배포 경로인 Play Store 워크플로에는 Firebase 단계가 없다. Firebase 프로젝트가 Play와 연동되지 않아(`PLAY_ACCOUNT_NOT_LINKED`) AAB는 배포할 수 없다.
