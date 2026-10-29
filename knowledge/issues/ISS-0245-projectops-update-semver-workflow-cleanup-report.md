---
type: completion-report
id: ISS-0245
created: 2026-10-08
topics: [ci-deploy, dev-workflow]
status: resolved
resolves: "[[ISS-0245-projectops-update-semver-workflow-cleanup]]"
related: ["[[DEC-0109-semver-auto-bump-on-main-merge]]", "[[DEC-0110-dependabot-exclude-major-updates]]"]
source: "https://github.com/Twin-Fang/passQL/issues/417"
---

# ISS-0245 완료 리포트: projectops 4.36.4, main 직행 semver 자동 승격, 워크플로우 47 → 32

GitHub #417 결과 댓글과 projectops 이슈 등록 댓글 기준 (PR #418, #422). `## 개요` 형식 리포트는 없음.

## 해결 방법
1. projectops 4.31.5 → 4.36.4: 기존 옵션 유지(한글 라벨·docker-ssh·app·모노레포 경로)로 full 업데이트. 사용자가 고친 워크플로우 19개는 projectops가 덮지 않고 유지(`incoming/`에 새 버전만 둠).
2. semver 자동 승격: VERSION-CONTROL이 main 직행 머지에도 `semver_auto`를 따르도록 수정 — push 구간 커밋을 `classify-bump`로 판정(feat→minor, `type!`→major, 그 외 patch). #418 머지 때는 `version.yml`(설정) 변경이 포함돼 가드가 "릴리스 머지"로 판정·건너뜀 → 같은 스크립트로 0.1.0 승격(#422), 태그 `v0.1.0`.
3. 워크플로우 정리(47 → 32): 범용 PR-PREVIEW 4종과 대체된 수동 템플릿 8종 제거. 업데이트가 되살린 TEMPLATE-UTIL-VERSION-SYNC·NONSTOP 2종은 커밋하지 않음. AI-CI는 빌드 검증용 빈 `.env.prod` 생성. dependabot 메이저 제외 → 기존 PR 9개가 닫히고 minor·patch 묶음 3개(#419~#421)로 재생성.

## 근본 원인 (확정)
이슈 본문 기준(develop 전제의 `semver_auto`, 미설정·중복 템플릿).

## 재발 방지
- 로컬 확인: 최근 커밋 → `minor`, fix/docs → `patch`, `feat!` → `major`, `0.0.251 --bump minor` → `0.1.0`.
- 템플릿 문제는 projectops 레포에 이슈 7건(#805 `semver_auto` 무시, #806 `version.yml` 변경 PR 릴리스 오판, #807 README VERSION UPDATE rebase 실패, #808 PR 프리뷰 삭제 job, #809 구세대 워크플로우 미표시, #810 지운 워크플로우 부활, #811 `version.yml` 주석 영어화)으로 등록.
- 남은 것: #419~#421 dependabot 묶음 PR은 빌드 결과를 보고 개별 판단. 다음 projectops 업데이트 때 VERSION-CONTROL 수정분 유지 확인. passQL 전용 PR-PREVIEW 2종도 #808과 같은 구조라 PR·이슈를 닫을 때마다 실패한다.

## 교훈
(원본에 없음, 볼트 정리) projectops 업데이트 뒤에는 지운 워크플로우가 되살아났는지, 로컬 수정본이 유지됐는지 확인한다.
