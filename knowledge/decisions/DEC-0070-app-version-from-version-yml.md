---
type: decision
id: DEC-0070
created: 2026-04-13
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0117-app-version-from-version-yml]]", "[[ISS-0117-app-version-from-version-yml-report]]"]
---

# DEC-0070: 웹 앱 버전(`__APP_VERSION__`)은 빌드 타임에 루트 `version.yml`을 직접 읽어 주입한다

## 문제 정의 (Context)
설정 화면 버전이 `client/package.json`의 `1.0.0`으로 표시됐다. `version_manager.sh`는 단일 프로젝트 기준이라 멀티 모듈 경로(`client/package.json`)를 동기화하지 못한다 (GitHub #210).

## 결정 (Decision)
`client/vite.config.ts`가 `../../version.yml`을 읽어 정규식 `/^version:\s*"([^"]+)"/m`로 버전을 뽑아 `__APP_VERSION__`에 주입한다(실패 시 `"0.0.0"`). `package.json` `version`은 빌드에 쓰지 않는다.

## 검토한 대안 (Alternatives)
- 방법 A — `version_manager.sh`에 `version_file_path` 옵션을 추가해 `client/package.json` 지정: 이슈 본문은 방법 B를 "스크립트 수정 없이 해결 가능하며 멀티 모듈 구조에 더 안전함 (권장)"이라고 적었고, 방법 B로 구현했다.
- `project_type`을 `react`로 전환 + `package.json` 버전을 먼저 낮추기: 이슈 본문의 작업 항목이었으나 리포트에서 미해결로 남김.
- YAML 파서(`js-yaml`) 사용: 리포트는 추가 의존성 없이 정규식으로 해결했다고만 적음. 비교 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 추가 의존성 없이 표시 버전이 `version.yml`과 일치.

**부정**
- `version_manager.sh` 멀티 모듈 문제와 `project_type` 전환은 미해결(리포트). `package.json`의 `"1.0.0"`이 남아 있다.

## 영향 범위 (Scope)
`client/vite.config.ts`, 레포 루트 `version.yml`, 웹 설정 화면 버전 표시.

## 출처 (References)
- GitHub #210 이슈 본문, 리포트 댓글 (2026-04-13)
- [[ISS-0117-app-version-from-version-yml]]
