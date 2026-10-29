---
type: completion-report
id: ISS-0196
created: 2026-10-07
topics: [ci-deploy, dev-workflow]
status: resolved
resolves: "[[ISS-0196-repo-transfer-to-twin-fang]]"
related: ["[[DEC-0098-move-repo-to-twin-fang]]"]
source: "https://github.com/Twin-Fang/passQL/issues/351"
---

# ISS-0196 완료 리포트: Twin-Fang 이전 후 첫 deploy 성공, 구 조직 정리 결정

GitHub #351 댓글 기준 ("배포 검증 완료", "완료", 2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 이전 후 첫 deploy: `PROJECT-SPRING-SYNOLOGY-PASSQL-CICD` run 37550276843 성공. 새로 등록한 시크릿으로 DockerHub 푸시와 시놀로지 SSH 배포 동작 확인.
- 운영 확인: `passql-back` 새 컨테이너 기동, `/actuator/health` 200, `/api/meta/topics` 200, `passql-ai`도 재배포.
- 코드·스크립트·문서의 레포 주소 변경(커밋 `eb6372b`).
- passQL-Lab에 남은 구 앱 레포 `passQL-app`은 모노레포 `app/`으로 이미 옮긴 상태라 불필요. git 기록 전체를 로컬 미러로 백업한 뒤 사용자가 조직째 삭제하기로 함.

## 근본 원인 (확정)
해당 없음 (작업 이슈).

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 레포를 다른 조직으로 옮길 때는 조직 시크릿을 다시 등록하고, 첫 deploy로 새 시크릿이 실제 동작하는지 확인한다.
