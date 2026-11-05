---
type: issue
id: ISS-0452
created: 2026-11-05
topics: [ci-deploy, store-release]
symptoms: ["서버 배포인데 스토어 심사 제출", "스토어 워크플로 자동 실행", "버전 커밋 pubspec", "심사 취소 위험", "paths app/**", PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml, PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml, store_submit]
root_cause: "릴리스 버전 커밋이 매번 app/pubspec.yaml version 줄을 바꿔 스토어 워크플로 자동 실행 경로(app/**)에 걸렸다"
status: resolved
resolution: "[[ISS-0452-server-only-release-triggers-store-submit-report]]"
related: ["[[ISS-0452-server-only-release-triggers-store-submit-report]]", "[[ISS-0422-play-closed-testing-promote-default-off]]"]
source: "https://github.com/Twin-Fang/passQL/issues/840"
---

# ISS-0452: 서버만 바꾼 릴리스에도 iOS·Android 스토어 심사 제출이 자동 실행됨

GitHub #840 이슈 본문 기준. 원본 사본: `_sources/issues/ISS-0452-server-only-release-triggers-store-submit.md` (로컬 전용). 완료 리포트: [[ISS-0452-server-only-release-triggers-store-submit-report]]

## 증상
서버만 바꾼 릴리스(main > deploy) 때 deploy 푸시로 iOS·Android 스토어 워크플로가 같이 시작돼 store_submit 까지 간다. 진행 중 심사가 새 제출로 취소될 수 있다([[ISS-0422-play-closed-testing-promote-default-off]]와 같은 위험). 2026-11-05 릴리스 3번 모두 수동 취소.

## 재현 조건
서버만 바꾼 PR 머지 > 릴리스 PR 머지 > deploy 푸시 실행 목록 확인.

## 근본 원인
릴리스 버전 커밋의 `app/pubspec.yaml` version 줄 변경이 `paths: ['app/**']`에 걸렸다.
