---
type: completion-report
id: ISS-0423
created: 2026-10-28
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0423-test-build-version-mismatch-android-ios]]"
related: ["[[DEC-0202-test-build-shared-version-adjust-no-block]]"]
source: "https://github.com/Twin-Fang/passQL/issues/731"
---

# ISS-0423 완료 리포트: Android도 같은 버전 판단, 최종 댓글에 조정 사유·병합 권장 안내

GitHub #731 리포트 댓글 기준 (PR #733, #734, #736).

## 해결 방법
- `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml`: iOS와 같은 `ios_release.py precheck-version --mode test`(iOS 번들 ID 기준), App Store Connect 키 설정 스텝, job output `version`은 판단 결과(조회 실패 시 `version.yml`).
- `.github/scripts/test_build_notice.py`(신규): `ℹ️ 버전 조정: …`, `⚠️ 이 브랜치의 version.yml(…)이 {기본 브랜치}(…)보다 낮습니다 …`. 기준 브랜치는 `github.event.repository.default_branch`. iOS·Android `진행 상황 최종 업데이트 - 성공` 댓글에 포함.
- `기본 브랜치 CI 스크립트 준비` 스텝: `origin/<기본 브랜치>`에서 `test_build_notice.py`, `ios_release.py`, `asc_client.py`, `build_number.py`를 `$RUNNER_TEMP/ci-scripts`로 꺼내 사용. 스크립트 준비·Android 버전 판단·안내 스텝은 `continue-on-error`.
- 검증: 최신 브랜치 #731 Android·iOS `1.67.4`, 오래된 브랜치 #701 Android·iOS `1.66.2` + 안내 2줄.

## 근본 원인 (확정)
버전 판단이 iOS에만 있었다.

## 재발 방지
- 테스트 빌드 워크플로에 새 스크립트를 추가할 때 기본 브랜치에서 꺼내 쓰거나, 없을 때도 빌드가 계속되게 해야 한다(#733 회귀 사례).
- iOS 기존 `ios_release.py` 호출은 여전히 대상 브랜치 파일 — 2026-10-02 이전 분기 브랜치는 iOS 빌드가 실패할 수 있다(기존 동작).
- Android에서만 App Store 조회가 실패하면 버전이 다시 갈릴 수 있다. 근본 해결안(트리거에서 한 번 정해 내려보내기)은 projectops #1006.

## 교훈
(원본에 없음, 볼트 정리) 기본 브랜치 정의로 돌고 대상 브랜치를 체크아웃하는 워크플로에서는 스크립트를 어느 브랜치에서 읽는지 먼저 확인한다.
