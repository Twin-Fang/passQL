---
type: issue
id: ISS-0179
created: 2026-10-02
topics: [ci-deploy, dev-workflow]
symptoms: ["flutter analyze 경고", asset_does_not_exist, "assets/.env", "호환되지 않는 패키지 106개", "앱 버전 불일치", "1.0.0+1", transformTimeout]
root_cause: "`.env` 에셋 처리 방침·린트·의존성·버전 기준이 정리되지 않음"
status: resolved
resolution: "[[ISS-0179-app-dependency-lint-build-cleanup-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/334"
---

# ISS-0179: 앱 의존성, 린트, 빌드 정리

GitHub #334 (원본: 이슈 본문과 댓글 2개).

## 증상
`flutter analyze`에서 `assets/.env` 에셋 없음 경고와 린트 1건, 최신 버전과 호환되지 않는 패키지 106개. 버전이 레포마다 달라(`1.0.0+1` vs `0.0.190+189`) 기준이 없다.

## 재현 조건
로컬에 `.env` 없이 `flutter analyze`/빌드 → `asset_does_not_exist` 경고.

## 조사 기록
- 2026-10-02 현황 측정: 작성 시점 문제는 이미 해소 — `flutter analyze` 0건(린트는 GitHub #329 중 해소), 안드로이드 빌드 차단(core library desugaring)은 GitHub #327에서 해소. 앱 버전은 모노레포 CI가 `app/pubspec.yaml`을 자동 관리하는 단일 기준(`1.0.0+1` 폐기).
- 업그레이드 중 dio 5.10+의 새 에러 종류 `transformTimeout` 때문에 에러 변환기가 컴파일되지 않음을 발견.

## 근본 원인
원본에 하나의 원인으로 적혀 있지 않다(정리 작업 이슈).
