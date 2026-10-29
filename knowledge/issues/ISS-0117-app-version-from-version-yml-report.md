---
type: completion-report
id: ISS-0117
created: 2026-04-13
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0117-app-version-from-version-yml]]"
related: ["[[DEC-0070-app-version-from-version-yml]]"]
source: "https://github.com/Twin-Fang/passQL/issues/210"
---

# ISS-0117 완료 리포트: `__APP_VERSION__`을 루트 `version.yml`에서 주입

GitHub #210 `## 개요` 리포트 댓글 기준 (2026-04-13), 같은 날 "Stable 적용 완료".

## 해결 방법
`client/vite.config.ts`: `package.json` 대신 `../../version.yml`을 `readFileSync` + `import.meta.url` 경로로 읽고 `/^version:\s*"([^"]+)"/m`로 버전 추출, 실패 시 `"0.0.0"`. 추가 의존성(`js-yaml` 등) 없음. → [[DEC-0070-app-version-from-version-yml]].

## 근본 원인 (확정)
`version_manager.sh`가 단일 프로젝트 기준이라 `client/package.json`을 동기화하지 못한다. 이번 작업은 이 문제를 고치지 않고 우회했다.

## 재발 방지
리포트 주의사항: `version_manager.sh`의 멀티 모듈 경로 문제와 `project_type` react 전환은 미해결 — 별도 이슈로 장기 처리. `package.json`의 `"1.0.0"`은 그대로 두며 빌드 타임에 쓰이지 않는다.

## 교훈
(원본에 없음, 볼트 정리) 웹 표시 버전이 이상하면 `vite.config.ts`의 `__APP_VERSION__` 소스가 `version.yml`인지부터 본다.
