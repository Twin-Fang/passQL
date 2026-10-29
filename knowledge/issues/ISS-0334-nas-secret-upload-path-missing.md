---
type: issue
id: ISS-0334
created: 2026-10-18
topics: [ci-deploy, ops-infra]
symptoms: [NAS 시크릿 백업, PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD, ENV_FILE backend/.env 저장, AI_ENV_FILE 구분, 값형 시크릿 누락, 서명 비밀번호 없음]
root_cause: "백업 워크플로가 `ENV_FILE`·`AI_ENV_FILE`을 `backend/` 아래로 저장하고, 값형 시크릿 13개는 올리지 않았다"
status: resolved
resolution: "[[ISS-0334-nas-secret-upload-path-missing-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/544"
---

# ISS-0334: NAS 시크릿 업로드 — 앱 .env·AI env 구분 오류와 값형 시크릿 누락

GitHub #544 (원본: 이슈 본문과 댓글).

## 증상
GitHub Secret을 NAS(`(NAS 경로 생략)`)에 백업하는 `PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD`가 일부만 올리고 구분도 틀린다.
- `ENV_FILE`(Flutter 앱 `.env`)이 `backend/.env`로, `AI_ENV_FILE`이 `backend/ai.env`로 저장된다.
- 시크릿 32개 중 13개(Apple·Android 서명 비밀번호, App Store Connect 키 ID·Issuer ID, 번들 ID, 프로비저닝 프로파일 이름, DockerHub, Vercel)가 NAS에 없다. 인증서 파일은 있는데 비밀번호가 없어 복구가 안 된다.
- 소셜 키가 빠진 `.env`로 빌드하면 "준비 중인 로그인 방법"이 되는데 NAS에 완전한 `.env`가 없어 추적이 어렵다.

## 재현 조건
백업 워크플로 실행 후 NAS 폴더 확인.

## 조사 기록
- 2026-10-18: 수정·main 반영, 워크플로 자동 실행 후 NAS 결과 확인.

## 근본 원인
워크플로의 저장 경로와 업로드 대상 목록이 틀렸다(이슈 본문).
