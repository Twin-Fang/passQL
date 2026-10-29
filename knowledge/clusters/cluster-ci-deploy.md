---
type: cluster
topic: ci-deploy
created: 2026-10-29
members: 58
status: active
related: []
---

# 클러스터: ci-deploy

## 이 주제는
CI/CD·배포·버전 관리·빌드

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 19개, 열린 이슈 2개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0009-main-verify-deploy-branch-release]] — `main`은 빌드 검증만, 실제 배포는 `deploy` 브랜치에서만 트리거
- [[DEC-0060-vercel-server-side-build-deploy]] — Vercel 배포 워크플로는 runner에서 빌드하지 않고 `vercel deploy --prod --yes`로 Vercel 서버 빌드에 맡긴다
- [[DEC-0070-app-version-from-version-yml]] — 웹 앱 버전(`__APP_VERSION__`)은 빌드 타임에 루트 `version.yml`을 직접 읽어 주입한다
- [[DEC-0092-container-restart-unless-stopped-in-workflow]] — 운영 백엔드·AI 컨테이너 재시작 정책은 `unless-stopped`로 통일하고 배포 워크플로우의 `docker run`에 고정한다
- [[DEC-0097-release-signing-key-properties]] — Android 릴리스 서명은 `key.properties` 기반, 키스토어·비밀번호는 저장소 밖(로컬·CI 시크릿)
- [[DEC-0098-move-repo-to-twin-fang]] — 레포를 `Twin-Fang/passQL`로 옮기고, 구 passQL-Lab 조직은 백업 후 삭제
- [[DEC-0109-semver-auto-bump-on-main-merge]] — main 직행 머지에도 `semver_auto: true` — 커밋 타입으로 버전 승격 판정
- [[DEC-0110-dependabot-exclude-major-updates]] — dependabot은 메이저 업데이트를 제외하고 minor·patch만 묶어서 받는다
- [[DEC-0111-traefik-blue-green-zero-downtime]] — 백엔드 배포는 시놀로지 기존 Traefik(8079) 경유 Blue-Green 무중단 방식으로 한다
- [[DEC-0115-android-play-build-from-main]] — Android Play 워크플로의 빌드 기준을 `deploy`에서 `main`으로 바꾼다 (iOS와 동일)
- [[DEC-0117-secret-files-nas-backup]] — GitHub Secret 파일은 main push마다 시놀로지에 백업하고, 새 키는 로컬·Secret·백업 블록을 한 번에 등록한다
- [[DEC-0124-brand-folder-generated-assets]] — 브랜드 자산 원본은 레포 루트 `brand/` 하나, 플랫폼 사본은 스크립트로만 생성하고 CI 해시 검사
- [[DEC-0129-image-sha-tags-rollback-dispatch]] — 서버 이미지는 브랜치·버전·`sha-` 태그 3개로 push하고, 롤백은 `rollback_image_tag` 입력으로 기존 Blue-Green 재사용
- [[DEC-0156-projectops-release-changelog-deploy-to-main]] — CHANGELOG는 자체 워크플로 대신 projectops 표준 `RELEASE-CHANGELOG`로, 배포 PR 방향은 `deploy → main`
- [[DEC-0164-ai-server-traefik-blue-green]] — AI 서버도 백엔드와 같은 Traefik blue/green으로 배포하고 drain은 75초
- [[DEC-0181-commit-ios-package-resolved]] — iOS `Podfile.lock`과 SPM `Package.resolved` 2개를 레포에 커밋해 의존성 버전을 고정한다
- [[DEC-0201-play-promote-closed-testing-default-false]] — Play 수동 배포의 비공개 테스트(alpha) 승급은 기본 끔 — 필요할 때만 체크해서 승급
- [[DEC-0202-test-build-shared-version-adjust-no-block]] — 앱 테스트 빌드는 막지 않고 닫힌 버전이면 다음 패치로 올리며, Android도 iOS 번들 ID 기준의 같은 판단을 쓴다

## 대체된 결정 (역사)
- [[DEC-0021-vercel-git-integration-deploy-branch]] → DEC-0060

## 관련 이슈
- [[ISS-0355-store-review-status-tracking-issue]] (open, GitHub #570) — 스토어 심사 상태 자동 알림 (구독용, 닫지 않음)
- [[ISS-0424-xcode27-pod-deployment-target]] (open, GitHub #732) — Xcode 27에서 iOS 빌드 실패 — Pod 최소 iOS 버전 미달
- [[ISS-0006-init-ai-and-spring-servers]] (resolved, GitHub #1) — AI 서버·Spring 서버 초기 프로젝트 구성
- [[ISS-0016-vercel-git-auto-deploy]] (resolved, GitHub #19) — Vercel Git Integration 자동 배포 설정
- [[ISS-0028-server-pr-preview-build-check]] (resolved, GitHub #38) — Spring/FastAPI PR Preview 빌드 워크플로우와 빌드체크 전용 명령어
- [[ISS-0051-vercel-generate-choices-405]] (resolved, GitHub #94) — Vercel 프로덕션에서 `generate-choices`가 405
- [[ISS-0086-deploy-branch-vercel-build-failure]] (resolved, GitHub #152) — deploy 브랜치 Vercel 빌드 실패
- [[ISS-0117-app-version-from-version-yml]] (resolved, GitHub #210) — 설정 화면 앱 버전이 실제 릴리즈와 불일치 (version.yml ↔ package.json)
- [[ISS-0127-vercel-deploy-build-check-step]] (resolved, GitHub #230) — Vercel 배포 워크플로우에 빌드 검증 단계가 없음
- [[ISS-0139-ai-qdrant-env-prod-config]] (resolved, GitHub #256) — prod `passql-ai`가 `localhost`로 Qdrant에 접속해 연결 실패
- [[ISS-0147-firebase-project-and-secrets]] (resolved, GitHub #272) — Firebase 서비스 계정·Secret 미등록으로 서버 기동 실패
- [[ISS-0151-actions-echo-corrupts-firebase-json]] (resolved, GitHub #280) — GitHub Actions `echo`가 Firebase JSON을 손상시켜 서버가 뜨지 않음
- [[ISS-0179-app-dependency-lint-build-cleanup]] (resolved, GitHub #334) — 앱 의존성, 린트, 빌드 정리
- [[ISS-0181-projectops-update-workflow-cleanup]] (resolved, GitHub #336) — projectops 최신 적용 및 워크플로우 정리
- [[ISS-0182-prod-container-down-restart-policy]] (resolved, GitHub #337) — 운영 서버 컨테이너 중단 복구 및 자동 재시작 설정
- [[ISS-0190-android-release-signing-key]] (resolved, GitHub #345) — Android 릴리스 서명 키 구성 (Play Store 업로드 준비)
- [[ISS-0192-play-closed-test-and-ios-review-submit]] (resolved, GitHub #347) — 스토어 출시 — Play 비공개 테스트 및 iOS 심사 제출
- [[ISS-0196-repo-transfer-to-twin-fang]] (resolved, GitHub #351) — 레포 조직 이전 — passQL-Lab → Twin-Fang
- [[ISS-0221-android-play-cicd-artifact-path]] (resolved, GitHub #376) — Android Play 배포 워크플로우가 `project-files` 산출물 경로 누락으로 실패
- [[ISS-0238-server-tests-not-compiling]] (resolved, GitHub #405) — `GreetingServiceTest` 컴파일 실패로 서버 테스트가 실행되지 않음
- [[ISS-0245-projectops-update-semver-workflow-cleanup]] (resolved, GitHub #417) — projectops 4.36.4 업데이트, semver 자동 승격, 워크플로우 정리
- [[ISS-0246-backend-traefik-blue-green-deploy]] (resolved, GitHub #423) — 백엔드 배포 중 약 45초 502 — Traefik Blue-Green 무중단 배포 전환
- [[ISS-0248-ops-log-retention-request-trace]] (resolved, GitHub #436) — 운영 로그 — 배포 시 유실, 헬스체크 노이즈, 요청 추적 불가, ANSI 혼입
- [[ISS-0254-projectops-4-40-play-closed-testing]] (resolved, GitHub #448) — Android 배포가 내부 테스트까지만 올라가고 비공개 테스트가 0.0.220에 머묾
- [[ISS-0255-projectops-4-44-1-update]] (resolved, GitHub #449) — projectops 템플릿 4.40.0 → 4.44.1 업데이트
- [[ISS-0258-github-secret-synology-backup]] (resolved, GitHub #452) — GitHub Secret 파일의 원본 백업이 없어 잃으면 복구 불가
- [[ISS-0262-issue-comment-app-test-build-fail]] (resolved, GitHub #456) — 이슈 댓글 앱 테스트 빌드(`@projectops app build`)가 Android·iOS 모두 실패
- [[ISS-0265-brand-assets-single-source]] (resolved, GitHub #459) — 브랜드 자산 사본이 플랫폼마다 따로 있어 수정이 빠짐
- [[ISS-0283-server-image-version-tag-rollback]] (resolved, GitHub #477) — 서버 이미지 태그가 덮어써져 롤백할 이미지가 없음
- [[ISS-0293-release-build-safeguards]] (resolved, GitHub #487) — 앱 릴리스 빌드 안전장치 부재
- [[ISS-0315-firebase-distribution-not-deployed]] (resolved, GitHub #513) — 스토어 배포 시 Firebase App Distribution 테스터에게 빌드가 배포되지 않음
- [[ISS-0332-changelog-not-updated-on-deploy]] (resolved, GitHub #542) — 배포할 때 CHANGELOG가 갱신되지 않는 문제
- [[ISS-0334-nas-secret-upload-path-missing]] (resolved, GitHub #544) — NAS 시크릿 업로드 — 앱 .env·AI env 구분 오류와 값형 시크릿 누락
- [[ISS-0349-ai-server-blue-green-deploy]] (resolved, GitHub #564) — AI 서버 배포를 백엔드와 같은 무중단(blue/green)으로 전환
- [[ISS-0353-android-production-access-not-granted]] (resolved, GitHub #568) — Android 프로덕션 승급 실패 — Play 계정 프로덕션 액세스 미승인
- [[ISS-0354-store-review-status-notifications]] (resolved, GitHub #569) — 스토어 심사 결과를 개인 메일로 받기 — 자동 상태 알림과 계정 알림 설정
- [[ISS-0403-ios-dependency-lockfiles-sync]] (resolved, GitHub #670) — iOS 의존성 고정 파일 갱신
- [[ISS-0422-play-closed-testing-promote-default-off]] (resolved, GitHub #729) — Play 수동 배포 비공개 테스트 승급 기본값 끄기
- [[ISS-0423-test-build-version-mismatch-android-ios]] (resolved, GitHub #731) — 앱 테스트 빌드가 같은 커밋인데 Android·iOS 버전이 다르게 올라감
