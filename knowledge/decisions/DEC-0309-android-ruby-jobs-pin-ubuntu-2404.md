---
type: decision
id: DEC-0309
created: 2026-11-05
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0515-android-ci-ruby-ubuntu-2604]]"]
---

# DEC-0309: Ruby(fastlane)를 쓰는 Android 잡은 Ruby 3.4.1 을 그대로 두고 러너를 `ubuntu-24.04` 로 고정한다

## 문제 정의 (Context)
`ubuntu-latest`가 ubuntu-26.04로 바뀌며 `ruby/setup-ruby` 3.4.1 설치가 실패해 Android 테스트 APK와 Play 배포가 막혔다 (GitHub #826, [[ISS-0515-android-ci-ruby-ubuntu-2604]]).

## 결정 (Decision)
- Ruby를 쓰는 Android 잡 4개(`build-android-test`, `deploy-playstore`, 셀프호스트·시놀로지 `build-android`)의 `runs-on`을 `ubuntu-24.04`로 고정하고 잡마다 이유 주석을 단다.
- Ruby 버전(3.4.1)은 바꾸지 않는다. iOS 잡(macOS 러너, Ruby 3.1)은 그대로 둔다.

## 검토한 대안 (Alternatives)
- Ruby 버전을 바꾸기: fastlane·Gemfile.lock이 3.4.1 기준으로 맞춰져 있어, 러너를 고정해 빌드 환경을 이전과 똑같이 두는 편이 위험이 가장 작다고 보고 버렸다(리포트 「핵심 구현」).

## 결과 (Consequences)
**긍정**
- 빌드 환경이 이전과 같아 즉시 복구됐다(테스트 APK 2회, Play 배포 성공).

**부정**
- `ubuntu-24.04` 이미지 종료 전에 setup-ruby의 26.04용 3.4.x 지원을 확인해 `ubuntu-latest`로 되돌리거나 Ruby 버전을 올려야 한다.

## 영향 범위 (Scope)
- `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml`, `PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`, `PROJECT-FLUTTER-ANDROID-SELFHOSTED-CICD.yaml`, `PROJECT-FLUTTER-ANDROID-SYNOLOGY-CICD.yaml`.

## 출처 (References)
- GitHub #826 이슈 본문과 구현 보고(PR #827): https://github.com/Twin-Fang/passQL/issues/826
