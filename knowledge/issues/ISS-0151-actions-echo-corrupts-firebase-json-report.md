---
type: completion-report
id: ISS-0151
created: 2026-04-25
topics: [ci-deploy, auth-member]
status: resolved
resolves: "[[ISS-0151-actions-echo-corrupts-firebase-json]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/280"
---

# ISS-0151 완료 리포트: `echo` → `printf '%s'` + 작은따옴표

GitHub #280 "구현 완료 보고" 댓글(2026-04-25) 기준.

## 해결 방법
`.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`의 application-prod.yml·firebase-service-account.json 생성 단계를 교체:
- 수정 전: `echo "${{ secrets.FIREBASE_SERVICE_ACCOUNT_JSON }}" > firebase-service-account.json`
- 수정 후: `printf '%s' '${{ secrets.FIREBASE_SERVICE_ACCOUNT_JSON }}' > firebase-service-account.json`

검증 중 함께 수정: SSH 포트를 기본 22 대신 NAS의 `port: 2022`로 명시, NAS에서 `docker`가 PATH에 없어 `(NAS 경로 생략)` 전체 경로 사용. 임시 워크플로우 `PROJECT-SPRING-SERVER-DEPLOY.yml`은 검증 후 삭제해 `PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`로 단일화.

## 근본 원인 (확정)
`echo "..."`의 shell 처리로 JSON 큰따옴표가 제거됐다.

## 재발 방지
댓글 주의사항: 시크릿 참조를 작은따옴표로 감싸는 것이 핵심 — 큰따옴표면 같은 문제가 재발할 수 있다. Synology NAS ssh-action에서는 docker 전체 경로를 써야 한다.

## 교훈
(원본에 없음, 볼트 정리) 배포 후 CORS 에러가 갑자기 나면 서버 기동 실패(설정 파일 손상)부터 의심한다.
