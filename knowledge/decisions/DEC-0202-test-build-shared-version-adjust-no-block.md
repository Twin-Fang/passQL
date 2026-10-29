---
type: decision
id: DEC-0202
created: 2026-10-28
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0423-test-build-version-mismatch-android-ios]]", "[[ISS-0423-test-build-version-mismatch-android-ios-report]]"]
---

# DEC-0202: 앱 테스트 빌드는 막지 않고 닫힌 버전이면 다음 패치로 올리며, Android도 iOS 번들 ID 기준의 같은 판단을 쓴다

## 문제 정의 (Context)
같은 커밋의 테스트 빌드가 Android `1.63.0`, iOS `1.66.2`로 갈렸다. 닫힌 버전 → 다음 패치 전환이 iOS에만 있었다 (GitHub #731).

## 결정 (Decision)
- 막는 방식은 쓰지 않고, App Store에서 닫힌 버전이면 다음 패치 버전으로 빌드하는 방식을 유지한다.
- Android 테스트 빌드도 iOS 번들 ID 기준의 `ios_release.py precheck-version --mode test`를 거친다. 조회 실패 시 `version.yml` 값.
- 최종 성공 댓글에 버전 조정 사유와 "기본 브랜치 병합 권장" 안내. 패치만 뒤처진 브랜치에는 경고하지 않는다.
- 테스트 빌드 스크립트는 기본 브랜치에서 꺼내 쓴다.

## 검토한 대안 (Alternatives)
리포트 「왜 이렇게 했나」:
- 막는 방식(ELUM에 남은 예전 방식): 출시 직후에는 기본 브랜치 `version.yml`도 닫힌 버전이라 다음 버전이 오르기 전까지 모든 iOS 테스트 빌드가 막힌다. projectops #643도 같은 이유로 올리는 방식을 골랐다.
- 단순히 낮은지만 비교해 경고: passQL은 main 머지마다 패치가 올라 거의 모든 브랜치에 경고가 붙어 버림.
- 대상 브랜치에서 스크립트 읽기: 새 스크립트 전 분기한 브랜치에는 파일이 없어 버림.
- 트리거에서 버전을 한 번 정해 내려보내기: 근본 해결안으로 projectops #1006에 남김(이번에 적용 안 함).

## 결과 (Consequences)
**긍정**
- 같은 커밋이 같은 버전으로 보여 테스트 결과 비교 가능(Firebase 배포에는 버전 제약이 없지만).

**부정**
- Android에서만 App Store 조회가 실패하면 버전이 다시 갈릴 수 있다.

## 영향 범위 (Scope)
`.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml`, `PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml`, `.github/scripts/test_build_notice.py`.

## 출처 (References)
- GitHub #731 이슈 본문 「예상 동작」, 리포트 「왜 이렇게 했나」
- [[ISS-0423-test-build-version-mismatch-android-ios]]
