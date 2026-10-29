---
type: issue
id: ISS-0028
created: 2026-04-09
topics: [ci-deploy]
symptoms: ["PR Preview", "server build", "server build-check", "테스트 서버 배포 워크플로우 없음", suh-github-template]
root_cause: "Spring/FastAPI 테스트 서버 배포 워크플로우가 없었고, 빌드만 확인할 때도 Preview 배포 전체 플로우를 태워야 했다"
status: resolved
resolution: "[[ISS-0028-server-pr-preview-build-check-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/38"
---

# ISS-0028: Spring/FastAPI PR Preview 빌드 워크플로우와 빌드체크 전용 명령어

GitHub #38 (원본: 이슈 본문과 댓글).

## 증상
Spring / FastAPI 서버의 테스트 서버 배포 워크플로우가 없었다. `suh-github-template`에 검증된 워크플로우(`PROJECT-SPRING-SYNOLOGY-PR-PREVIEW.yaml`, `PROJECT-SPRING-SYNOLOGY-SIMPLE-CICD.yaml`, `PROJECT-PYTHON-SYNOLOGY-PR-PREVIEW.yaml`, `PROJECT-PYTHON-SYNOLOGY-CICD.yaml`)가 있었으나 미적용. 빌드 가능 여부만 확인하고 싶어도 Preview 배포 전체 플로우를 태워야 해 리소스·시간이 낭비됐다.
제안: 템플릿 워크플로우 4종 이식(PR 코멘트 `@suh-lab server build`로 테스트 서버 빌드·배포), 배포 없는 빌드체크 명령(`@suh-lab server build-check`, Spring `./gradlew clean build -x test`, FastAPI import/부트 체크), Secrets 목록·사용법 문서.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-04-10: "정상작동 확인했습니다" 댓글, 확인 위치로 GitHub #52(이전 저장소 링크)를 안내.

## 근본 원인
해당 없음 (기능 이슈).
