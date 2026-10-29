---
type: issue
id: ISS-0245
created: 2026-10-08
topics: [ci-deploy, dev-workflow]
symptoms: ["projectops 4.31.5", "버전이 patch만 오름", semver_auto, VERSION-CONTROL, PR-PREVIEW, "rate limit", "AI-CI .env.prod 없음", "dependabot 메이저 PR"]
root_cause: "`semver_auto`가 develop→main 릴리스 경로에서만 읽히는데 이 레포는 main 직행이었고, 미설정 템플릿·중복 워크플로우가 실패 알림을 쌓았다"
status: resolved
resolution: "[[ISS-0245-projectops-update-semver-workflow-cleanup-report]]"
related: ["[[DEC-0109-semver-auto-bump-on-main-merge]]", "[[DEC-0110-dependabot-exclude-major-updates]]"]
source: "https://github.com/Twin-Fang/passQL/issues/417"
---

# ISS-0245: projectops 4.36.4 업데이트, semver 자동 승격, 워크플로우 정리

GitHub #417 (원본: 이슈 본문과 댓글 2개).

## 증상
- projectops 템플릿이 4.31.5로 최신(4.36.4)보다 뒤처짐.
- 버전이 항상 patch만 오름 — `semver_auto`는 develop→main 릴리스 경로에서만 읽히는데 이 레포는 develop 없이 main 직행.
- 워크플로우 47개 중 다수가 미설정 템플릿·중복이라 실패 알림이 쌓임: PR-PREVIEW 6종이 이슈 댓글·닫힘마다 전부 실행 → 일괄 처리 때 rate limit 실패, AI-CI가 `.env.prod` 없음으로 `ai/**` 변경마다 실패, dependabot 메이저 업데이트 PR(Spring Boot 4, TypeScript 7 등)이 빌드 실패로 쌓임.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-10-08: 해결 방안 — `npx projectops@latest` full 업데이트(기존 옵션 유지), VERSION-CONTROL이 main 직행 머지에도 `semver_auto`를 따르게, 미사용·중복 워크플로우 제거, AI-CI 수정, dependabot 메이저 제외.
- 2026-10-08: 템플릿 문제 7건을 projectops 레포 이슈(Cassiiopeia/projectops#805~#811)로 등록.

## 근본 원인
버전 승격 판정이 develop 경로를 전제했고, 쓰지 않는 템플릿 워크플로우가 설치돼 있었다.
