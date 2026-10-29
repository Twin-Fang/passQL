---
type: completion-report
id: ISS-0334
created: 2026-10-18
topics: [ci-deploy, ops-infra]
status: resolved
resolves: "[[ISS-0334-nas-secret-upload-path-missing]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/544"
---

# ISS-0334 완료 리포트: 앱·AI env 경로 바로잡고 값형 시크릿을 역할별 `.env`로 묶어 NAS 백업

GitHub #544 개요 댓글 기준 (2026-10-18).

## 해결 방법
- `ENV_FILE` → `app/.env`, `AI_ENV_FILE` → `ai/.env`.
- 값형 시크릿을 역할별 파일로 묶어 업로드: `app/store-signing-values.env`, `backend/dockerhub.env`, `web/vercel.env`.
- 값은 따옴표 처리한 heredoc으로 읽어 특수문자가 스크립트를 깨지 않게, 비어 있는 키는 쓰지 않고 모두 비면 스킵.
- 시크릿을 바꾼 뒤 `workflow_dispatch`로 수동 실행해야 NAS가 갱신된다는 안내를 주석에 추가.
- 실측: `app/.env`(600, 20줄, 소셜 키 4개 포함), `ai/.env`(600, 13줄), 값 묶음 3개(600). 시크릿 32개 모두 NAS로 올라가는 상태.

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
- 시크릿 변경 후 수동 실행으로 NAS를 갱신한다.
- 이전에 잘못 저장된 `backend/.env`가 NAS에 남아 있다(삭제는 사용자 확인 후).

## 교훈
(원본에 없음, 볼트 정리) 인증서 같은 파일 시크릿만 백업하고 비밀번호 같은 값형 시크릿을 빼면 복구가 불가능하다 — 백업 대상은 복구 시나리오 기준으로 점검한다.
