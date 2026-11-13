---
type: issue
id: ISS-0515
created: 2026-11-05
topics: [ci-deploy]
symptoms: ["Unavailable version 3.4.1 for ruby on ubuntu-26.04", "Set up Ruby 실패", ruby/setup-ruby, ubuntu-latest, ubuntu-26.04, "Android 테스트 APK 빌드 실패", deploy-playstore, build-android-test]
root_cause: "ubuntu-latest 러너가 ubuntu-26.04 로 바뀌었는데 그 러너용 미리 빌드된 Ruby 목록에 워크플로가 고정한 3.4.1 이 없었다"
status: resolved
resolution: "[[ISS-0515-android-ci-ruby-ubuntu-2604-report]]"
related: ["[[DEC-0309-android-ruby-jobs-pin-ubuntu-2404]]", "[[ISS-0361-billing-switch-final-checks]]"]
source: "https://github.com/Twin-Fang/passQL/issues/826"
---

# ISS-0515: Android 앱 빌드 Ruby 3.4.1 설치 실패 (ubuntu-latest > ubuntu-26.04)

GitHub #826. [[ISS-0361-billing-switch-final-checks]](#596) 작업 중 발견.

## 증상
- Android 앱 빌드 워크플로의 `Set up Ruby` 단계 실패: `Error: Unavailable version 3.4.1 for ruby on ubuntu-26.04`.
- 영향: 브랜치 테스트 APK(`@projectops app build`)가 Fastlane 전에 실패, Play 내부 테스트 배포(`deploy-playstore`)도 같은 설정. 셀프호스트·시놀로지 Android 워크플로도 같은 설정(당시 미사용).
- iOS 워크플로는 macOS 러너 + Ruby 3.1이라 무관.

## 재현 조건
이슈에 `@projectops app build <브랜치>` 댓글 > Android 테스트 APK 빌드 > `Set up Ruby`.

## 조사 기록
- 2026-11-04(UTC): #596 브랜치 테스트 APK에서 실패 확인.

## 근본 원인
`ruby/setup-ruby`에 `ruby-version: "3.4.1"`을 고정했는데 ubuntu-26.04용 빌드가 없었다.
