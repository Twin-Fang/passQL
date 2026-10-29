---
type: decision
id: DEC-0109
created: 2026-10-08
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0245-projectops-update-semver-workflow-cleanup]]", "[[ISS-0245-projectops-update-semver-workflow-cleanup-report]]"]
---

# DEC-0109: main 직행 머지에도 `semver_auto: true` — 커밋 타입으로 버전 승격 판정

GitHub #417 (원본: 이슈 본문 「해결 방안」과 결과 댓글).

## 문제 정의 (Context)
버전이 항상 patch만 올랐다. `semver_auto`는 develop→main 릴리스 경로에서만 읽히는데 이 레포는 develop 없이 main 직행이었다.

## 결정 (Decision)
VERSION-CONTROL이 main 직행 머지에도 `semver_auto`를 따르게 로컬 수정하고 `semver_auto: true`로 둔다. push 구간 커밋을 `classify-bump`로 판정: feat → minor, `type!` → major, 그 외 patch. 이 결정으로 0.0.251 → `0.1.0`(#422, 태그 `v0.1.0`).

## 검토한 대안 (Alternatives)
논의 기록 없음. (원본은 develop 브랜치를 도입하는 방안을 다루지 않았다.)

## 결과 (Consequences)
**긍정**
- 커밋 타입에 따라 minor·major가 자동으로 오른다.

**부정 / 조건**
- `version.yml`(설정) 변경이 포함된 머지는 가드가 "릴리스 머지"로 판정해 건너뛴다(#418 사례, projectops#806).
- VERSION-CONTROL 로컬 수정분이 다음 projectops 업데이트에 유지되는지 확인해야 한다 (원본 「남은 것」).

## 영향 범위 (Scope)
VERSION-CONTROL 워크플로우, `version.yml`, `classify-bump` 스크립트. 기존 결정 DEC-0009(`main`은 빌드 검증, `deploy` 브랜치 배포)와의 관계는 원본에 적혀 있지 않다.

## 출처 (References)
- GitHub #417 이슈 본문, 결과 댓글(PR #418, #422, 2026-10-08)
- [[ISS-0245-projectops-update-semver-workflow-cleanup]]
