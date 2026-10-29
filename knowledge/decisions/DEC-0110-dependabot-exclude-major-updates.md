---
type: decision
id: DEC-0110
created: 2026-10-08
reviewed: null
topics: [ci-deploy, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0245-projectops-update-semver-workflow-cleanup]]", "[[ISS-0245-projectops-update-semver-workflow-cleanup-report]]"]
---

# DEC-0110: dependabot은 메이저 업데이트를 제외하고 minor·patch만 묶어서 받는다

GitHub #417 (원본: 이슈 본문 「해결 방안」과 결과 댓글).

## 문제 정의 (Context)
dependabot 메이저 업데이트 PR(Spring Boot 4, TypeScript 7 등)이 빌드 실패로 쌓였다.

## 결정 (Decision)
dependabot 설정에서 메이저 업데이트를 제외한다. 결과로 기존 PR 9개가 닫히고 minor·patch 묶음 3개(#419~#421)로 재생성됐다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 빌드 실패 PR이 쌓이지 않는다 (이슈의 문제 제기 기준).

**부정 / 조건**
- 묶음 PR(#419~#421)은 빌드 결과를 보고 개별 판단 (원본 「남은 것」).
- (원본에 없음, 볼트 정리) 메이저 업그레이드는 자동 PR로 오지 않으므로 필요하면 따로 챙겨야 한다.

## 영향 범위 (Scope)
dependabot 설정 파일(경로는 원본에 적혀 있지 않다).

## 출처 (References)
- GitHub #417 이슈 본문, 결과 댓글(2026-10-08)
- [[ISS-0245-projectops-update-semver-workflow-cleanup]]
