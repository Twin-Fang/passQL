---
type: decision
id: DEC-0115
created: 2026-10-10
reviewed: null
topics: [ci-deploy, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0254-projectops-4-40-play-closed-testing]]", "[[ISS-0254-projectops-4-40-play-closed-testing-report]]"]
---

# DEC-0115: Android Play 워크플로의 빌드 기준을 `deploy`에서 `main`으로 바꾼다 (iOS와 동일)

## 문제 정의 (Context)
projectops 4.40.0 업데이트 후 1차 실행이 `deploy`(v0.5.1) 브랜치를 빌드해 `Version code 267 has already been used`로 실패했다. 이전 내부 테스트의 Android 0.5.1도 `deploy` 시점 빌드라 최신 앱이 아니었다 (GitHub #448).

## 결정 (Decision)
Android Play 워크플로는 `main`을 빌드한다. "이제 iOS와 같이 `main`이 나갑니다"(완료 보고).

## 검토한 대안 (Alternatives)
논의 기록 없음. (이전 방식은 `deploy` 브랜치 빌드.)

## 결과 (Consequences)
**긍정**
- 스토어 테스트 트랙에 최신 앱이 나간다, iOS와 기준이 같아진다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
Android Play 배포 워크플로 (`PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD`, #453 원본 표기).

## 출처 (References)
- GitHub #448 완료 보고 댓글 (2026-10-10)
