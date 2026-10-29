---
type: completion-report
id: ISS-0073
created: 2026-04-11
topics: [ai, ops-infra]
status: resolved
resolves: "[[ISS-0073-ai-server-401-env-file-missing]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/125"
---

# ISS-0073 완료 리포트: `.env.{env}`가 없으면 `.env`로 fallback

GitHub #125 리포트 댓글 기준 (2026-04-11).

## 해결 방법
`ai/src/core/config.py`에서 `_env_file = _env_file_primary if os.path.exists(_env_file_primary) else ".env"`. prod는 `.env.prod`가 없어 `.env`를, dev는 `.env.dev`를 읽는다.

## 근본 원인 (확정)
환경별 env 파일이 없을 때 API 키가 빈 문자열로 로드됐다.

## 재발 방지
리포트 주의사항: `.env`, `.env.dev`, `.env.prod`는 모두 `.gitignore` 대상이라 별도 관리. `AI_SERVER_API_KEY` 변경 시 Python 서버 재배포 필요(당시 Redis/DB 동적 관리 미적용).

## 교훈
(원본에 없음, 볼트 정리) AI 서버 401이면 키 값보다 먼저 컨테이너 안에 어떤 env 파일이 실제로 로드됐는지 본다. fallback 경로가 장애를 가려 증상이 늦게 드러날 수 있다.
