---
type: issue
id: ISS-0423
created: 2026-10-28
topics: [ci-deploy]
symptoms: ["Android iOS 테스트 빌드 버전 다름", "@projectops app build", precheck-version, "버전 조정", "version.yml 낡음", test_build_notice.py, "빌드 안내 문구 생성 실패"]
root_cause: "App Store에서 닫힌 버전이면 다음 패치로 바꾸는 처리가 iOS 테스트 빌드에만 있었고, 조정 사유가 최종 댓글에서 사라졌다"
status: resolved
resolution: "[[ISS-0423-test-build-version-mismatch-android-ios-report]]"
related: ["[[DEC-0202-test-build-shared-version-adjust-no-block]]"]
source: "https://github.com/Twin-Fang/passQL/issues/731"
---

# ISS-0423: 앱 테스트 빌드가 같은 커밋인데 Android·iOS 버전이 다르게 올라감

GitHub #731 (원본: 이슈 본문과 댓글).

## 증상
`@projectops app build`를 같은 커밋으로 돌렸는데 Android와 iOS 앱 버전이 다르다. GitHub #701: Android `1.63.0(89076685)`, iOS `1.66.2(89077499)` (커밋 `7eea520`). 이유가 최종 댓글에 적혀 있지 않다.

## 재현 조건
`version.yml`이 App Store에서 닫힌 버전 이하인 오래된 브랜치에 `@projectops app build <브랜치>` 댓글.

## 조사 기록
- 이슈 본문 원인: iOS 테스트 빌드는 닫힌 버전이면 다음 패치로 바꾼다(`ios_release.py precheck-version --mode test`), Android에는 없다. 전환 사유(`ℹ️ 버전 조정`)가 중간 진행 댓글에만 찍힘. 브랜치가 최신 main을 받지 않아 `version.yml`이 낡았다는 사실이 드러나지 않음.
- 템플릿 이슈: Cassiiopeia/projectops#1006 (4.77.0에서도 같은 구조).
- 2026-10-28 수정(PR #733, #734, #736). #733 직후 회귀: 기본 브랜치를 받지 않은 브랜치에서 `빌드 안내 문구 생성` 스텝 실패(`test_build_notice.py`가 그 브랜치에 없음) → #736으로 수정.

## 근본 원인
플랫폼별로 다른 버전 판단과 최종 댓글의 사유 누락.
