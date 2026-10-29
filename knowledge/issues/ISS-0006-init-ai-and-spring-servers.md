---
type: issue
id: ISS-0006
created: 2026-04-06
topics: [ci-deploy, ops-infra]
symptoms: ["서버 초기화 전", "빈 프로젝트", "AI 서버", "Spring 서버", 멀티모듈, "GitHub Actions"]
root_cause: "AI 서버와 Spring 서버가 초기화되지 않은 빈 상태라 개발을 시작할 수 없었다 (기능 이슈)"
status: resolved
resolution: "[[ISS-0006-init-ai-and-spring-servers-report]]"
related: ["[[DEC-0009-main-verify-deploy-branch-release]]", "[[DEC-0010-spring-multimodule-layering]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1"
---

# ISS-0006: AI 서버·Spring 서버 초기 프로젝트 구성

GitHub #1 (원본: 이슈 본문과 댓글).

## 증상
AI 서버와 Spring 서버가 완전한 빈 상태로, 기본 프로젝트 구조와 설정이 없어 개발을 시작할 수 없었다.
작업 항목: Spring 서버 초기화(Spring Initializr 기반 골격), AI 서버 초기화(디렉토리 구조·환경 설정), 각 서버 README·실행 방법 문서화.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-06: 빌드 체크 완료, git secret 등록 완료.
- 2026-04-06: coderabbitai 연결 완료. 버전 증가·deploy·coderabbitai summary·changelog·자동 머지 정상 작동 확인 (PR 링크는 이전 저장소 PR #4).
- 2026-04-06: `deploy` 브랜치 push 시 CI/CD가 실행되지 않는 경우는 `paths` 필터에 의한 의도된 동작이라는 설명 댓글. `PROJECT-SPRING-SYNOLOGY-PASSQL-CICD`는 `server/**`, `PROJECT-PYTHON-AI-CICD`는 `ai/**` 변경이 있어야 실행된다. 코드 변경 없는 재배포는 `workflow_dispatch`로 수동 실행.
- 2026-04-06: AI 서버·Spring 서버 CICD 확인 완료.

## 근본 원인
해당 없음 (기능 이슈 — 초기 구성 전 상태).
