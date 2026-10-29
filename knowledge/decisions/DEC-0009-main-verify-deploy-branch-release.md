---
type: decision
id: DEC-0009
created: 2026-04-06
reviewed: null
topics: [ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0006-init-ai-and-spring-servers]]", "[[ISS-0006-init-ai-and-spring-servers-report]]", "[[DEC-0115-android-play-build-from-main]]"]
---

# DEC-0009: `main`은 빌드 검증만, 실제 배포는 `deploy` 브랜치에서만 트리거

## 문제 정의 (Context)
GitHub #1에서 AI 서버와 Spring 서버를 처음 구성하면서 CI/CD 워크플로우를 만들었다.

## 결정 (Decision)
`main` 브랜치에서는 빌드 검증만 수행하고, `deploy` 브랜치에서만 실제 배포가 트리거되도록 워크플로우를 분리한다 (리포트 「CI/CD 분리 전략」). 배포 워크플로우는 `deploy` push와 해당 경로 변경(`server/**` 또는 `ai/**`)이 동시에 충족될 때만 실행되며, 이는 의도된 동작이다. 코드 변경 없는 재배포는 `workflow_dispatch`로 수동 실행한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 문서·README만 바뀐 push는 배포 워크플로우가 실행되지 않는다 (원본의 동작 예시 표).

## 영향 범위 (Scope)
`.github/workflows/PROJECT-PYTHON-AI-CI.yaml`, `PROJECT-SPRING-PASSQL-CI.yaml`, `PROJECT-PYTHON-AI-CICD.yaml`, `PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`.

## 출처 (References)
- GitHub #1 `## 개요` 리포트 댓글, `paths` 필터 동작 설명 댓글 (2026-04-06)
- [[ISS-0006-init-ai-and-spring-servers]]
