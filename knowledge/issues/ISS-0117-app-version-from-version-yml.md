---
type: issue
id: ISS-0117
created: 2026-04-13
topics: [ci-deploy]
symptoms: [__APP_VERSION__, "앱 버전 1.0.0 표시", project_type, version_manager.sh, "client/package.json", get_higher_version, vite.config.ts]
root_cause: "version_manager.sh가 단일 프로젝트 기준이라 client/package.json을 동기화하지 못하고, 빌드가 package.json의 1.0.0을 주입했다"
status: resolved
resolution: "[[ISS-0117-app-version-from-version-yml-report]]"
related: ["[[DEC-0070-app-version-from-version-yml]]"]
source: "https://github.com/Twin-Fang/passQL/issues/210"
---

# ISS-0117: 설정 화면 앱 버전이 실제 릴리즈와 불일치 (version.yml ↔ package.json)

GitHub #210 (원본: 이슈 본문, 리포트 댓글, "Stable 적용 완료" 댓글).

## 증상
설정 화면 앱 버전이 `1.0.0`으로 표시. `version.yml`의 `project_type`이 `"basic"`이라 워크플로우가 `package.json`을 동기화하지 않고, `package.json` `version`이 `"1.0.0"`으로 고정되어 `__APP_VERSION__`이 실제 릴리즈(`0.0.115`)와 다르다.

## 재현 조건
설정 화면의 버전 row 확인.

## 조사 기록
- 2026-04-13: 이슈 본문 분석 — `react` 타입으로 바꿔도 `version_manager.sh`는 `VERSION_FILE="package.json"`을 레포 루트에서 찾아 `client/package.json`을 못 찾는다. 또 `get_higher_version`이 높은 버전을 우선하므로 `package.json`이 `1.0.0`인 채 전환하면 `version.yml`이 `1.0.0`으로 덮어써진다. 해결 후보: 방법 A(`version_manager.sh`에 `version_file_path` 옵션) / 방법 B(`vite.config.ts`가 `version.yml` 직접 파싱, 권장).

## 근본 원인
버전 관리 스크립트가 멀티 모듈 경로를 지원하지 않고, 빌드 타임 버전 소스가 동기화되지 않는 `package.json`이었다.
