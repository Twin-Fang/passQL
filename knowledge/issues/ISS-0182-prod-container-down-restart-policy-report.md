---
type: completion-report
id: ISS-0182
created: 2026-10-07
topics: [ops-infra, ci-deploy]
status: resolved
resolves: "[[ISS-0182-prod-container-down-restart-policy]]"
related: ["[[DEC-0092-container-restart-unless-stopped-in-workflow]]"]
source: "https://github.com/Twin-Fang/passQL/issues/337"
---

# ISS-0182 완료 리포트: 컨테이너 복구, Spring 배포 워크플로우에 `--restart unless-stopped` 고정

GitHub #337 복구 댓글(2026-10-02)과 `## 개요` 리포트 댓글(2026-10-07, "#337 후속") 기준.

## 해결 방법
- 2026-10-02: 백엔드·AI 재시작 정책 `unless-stopped`로 변경 후 기동, `/actuator/health` 200, `/api/meta/topics` 200 확인.
- 2026-10-07: `.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`의 `docker run -d`에 `--restart unless-stopped` 추가(커밋 `2ccd31e`). 운영 `passql-back`은 `docker update --restart unless-stopped` 적용 후 재조회로 확인. `passql-ai`는 `PROJECT-PYTHON-AI-CICD.yaml`에 원래 지정.
- 검증: 배포 워크플로우(Vercel · Spring · AI) 모두 success, `Started PassqlApplication`(v0.0.245), Swagger 200(재시작 직후 일시 502), AI `/health` `{"status":"ok"}`, 웹 200, 정책 `no` → `unless-stopped`.

## 근본 원인 (확정)
원인은 컨테이너가 아니라 컨테이너를 만드는 쪽(배포 워크플로우)이었다.

## 재발 방지
- 워크플로우 수정은 main에 있고 배포는 deploy 브랜치의 워크플로우 파일로 돌기 때문에, 다음 배포에서 main을 deploy에 병합해야 반영된다.
- 다음 배포 후 `docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' passql-back`이 `unless-stopped`인지 확인.
- projectops 템플릿 업데이트로 이 워크플로우가 덮어써지면 옵션이 다시 빠질 수 있다.
- 헬스 모니터링·알림, DB 백업은 GitHub #339로 이관.

## 교훈
(원본에 없음, 볼트 정리) 운영 컨테이너 설정을 `docker update`로 고쳤다면 같은 값을 컨테이너를 만드는 배포 워크플로우에도 넣었는지 확인한다.
