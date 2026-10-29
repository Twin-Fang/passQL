---
type: decision
id: DEC-0092
created: 2026-10-02
reviewed: null
topics: [ops-infra, ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0182-prod-container-down-restart-policy]]", "[[ISS-0182-prod-container-down-restart-policy-report]]"]
---

# DEC-0092: 운영 백엔드·AI 컨테이너 재시작 정책은 `unless-stopped`로 통일하고 배포 워크플로우의 `docker run`에 고정한다

## 문제 정의 (Context)
NAS 재부팅 뒤 백엔드 컨테이너가 재시작 정책 `no` 때문에 7주간 기동되지 않아 운영 API가 502였다 (GitHub #337).

## 결정 (Decision)
- 재시작 정책을 `unless-stopped`로 통일한다(2026-10-02, 이슈 본문 "재시작 정책 `unless-stopped` 통일").
- 정책은 운영 컨테이너에만 `docker update`로 걸지 않고, 컨테이너를 만드는 배포 워크플로우의 `docker run -d`에 `--restart unless-stopped`로 고정한다(2026-10-07, `.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`, 커밋 `2ccd31e`). AI 워크플로우 `PROJECT-PYTHON-AI-CICD.yaml`과 실행 옵션을 맞췄다.

## 검토한 대안 (Alternatives)
- 운영 컨테이너만 `docker update`: 2026-10-02에 했으나 배포마다 정책이 `no`로 초기화되어 부족했다(원본).

## 결과 (Consequences)
**긍정**
- NAS 재부팅 후에도 백엔드가 자동 기동된다.

**부정 / 조건**
- deploy 브랜치에 main이 병합되기 전 컨테이너가 다시 만들어지면 정책이 `no`로 돌아간다.
- projectops 템플릿 업데이트로 워크플로우가 덮어써지면 옵션이 다시 빠질 수 있다.

## 영향 범위 (Scope)
`.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`, `PROJECT-PYTHON-AI-CICD.yaml`, 시놀로지 NAS의 `passql-back`·`passql-ai` 컨테이너.

## 출처 (References)
- GitHub #337 이슈 본문, 복구 댓글(2026-10-02), 리포트 댓글(2026-10-07)
