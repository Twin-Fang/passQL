---
type: completion-report
id: ISS-0497
created: 2026-11-05
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0497-android-ci-ruby-ubuntu-2604]]"
related: ["[[DEC-0293-android-ruby-jobs-pin-ubuntu-2404]]"]
source: "https://github.com/Twin-Fang/passQL/issues/826"
---

# ISS-0497 완료 리포트: Ruby 쓰는 Android 잡 4개를 ubuntu-24.04 로 고정

GitHub #826 구현 보고 (2026-11-05). PR #827 머지(2026-11-05).

## 해결 방법
- `.github/workflows/` 4개 잡의 `runs-on: ubuntu-latest`를 `ubuntu-24.04`로 바꿨다: `PROJECT-FLUTTER-ANDROID-TEST-APK.yaml`(`build-android-test`), `PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`(`deploy-playstore`), `PROJECT-FLUTTER-ANDROID-SELFHOSTED-CICD.yaml`·`PROJECT-FLUTTER-ANDROID-SYNOLOGY-CICD.yaml`(`build-android`).
- 잡마다 이유 주석 한 줄(`# ruby/setup-ruby 3.4.1 이 ubuntu-26.04 에 없어 24.04 고정 (#826)`).

## 근본 원인 (확정)
러너 이미지 변경으로 고정한 Ruby 버전의 빌드가 사라졌다.

## 재발 방지
- `ubuntu-24.04` 이미지도 언젠가 종료된다. 그 전에 setup-ruby가 26.04용 3.4.x를 지원하는지 확인하고, 지원하면 `ubuntu-latest`로 되돌리거나 Ruby 버전을 올린다.

## 교훈
- 검증: 2026-11-05 #596 브랜치 Android 테스트 APK 2회 연속 성공, 같은 날 deploy push의 Play 배포(`deploy-playstore`) 성공.
- 같은 날 iOS 스토어 배포 실패는 다른 원인이다(심사 대기 중인 버전에 새 빌드를 붙이지 못한 App Store Connect 상태 문제). TestFlight 업로드는 성공.
