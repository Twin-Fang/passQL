---
type: completion-report
id: ISS-0424
created: 2026-11-07
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0424-xcode27-pod-deployment-target]]"
related: ["[[ISS-0415-feedback-single-submit-attachments-diagnostics]]"]
source: "https://github.com/Twin-Fang/passQL/issues/732"
---

# ISS-0424 완료 리포트: Podfile post_install 에서 15.0 미만 Pod 타깃만 앱 기준 15.0 으로 올림

GitHub #732 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/732#issuecomment-6702514453). 이슈 닫힘. 원본 사본: `_sources/issues/ISS-0424-xcode27-pod-deployment-target-report.md`(로컬).

## 해결 방법
- 커밋 `3273f8ed`, PR #735 (2026-10-29 main 병합), 처음 포함된 버전 v1.70.2.
- `app/ios/Podfile`: `post_install`에서 최소 iOS 버전이 15.0 미만인 Pod 타깃만 15.0으로 올린다. 15.0 이상 타깃은 건드리지 않는다.
- `app/ios/Podfile.lock`: 새로 들어온 `battery_plus`, `connectivity_plus` 반영.

## 검증
- 이 이슈 브랜치 앱 빌드에서 iOS TestFlight 빌드와 업로드 성공 (앱 버전 1.67.6). 같은 브랜치 첫 빌드는 환경 준비 단계에서 실패했고 다시 요청한 빌드가 통과했다.
- 이후 스토어 빌드도 계속 성공 (iOS 1.77.1 판매 가능, 2026-11-05).

## 근본 원인 (확정)
이슈 노트와 같음. Pod 타깃의 최소 iOS 버전 선언(9.0~13.0)이 Xcode 27 지원 범위(15.0부터) 밖이라 빌드 오류.

## 재발 방지
- `post_install`의 기준값 15.0은 `Podfile`의 `platform :ios, '15.0'`과 같은 값이다. 앱 최소 지원 버전을 바꿀 때 두 값을 함께 바꾼다.

## 남은 일
없음. 빌드 설정 변경이라 화면 캡처 불필요.

## 교훈
로컬 시뮬레이터 빌드의 Xcode 27 `lipo -verify_arch` 문제([[ISS-0415-feedback-single-submit-attachments-diagnostics]] 후속 보고)는 다른 원인이다. Xcode 27 빌드 실패를 보면 Pod 최소 버전 오류인지 아키텍처 검사 오류인지 먼저 가른다.
