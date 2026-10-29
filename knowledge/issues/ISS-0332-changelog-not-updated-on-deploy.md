---
type: issue
id: ISS-0332
created: 2026-10-18
topics: [ci-deploy]
symptoms: [CHANGELOG 갱신 안 됨, v0.0.190에서 멈춤, RELEASE-CHANGELOG 미동작, AUTO-CHANGELOG-CONTROL 교체, "'v{버전} 업데이트' 폴백", TestFlight What to Test]
root_cause: "2026-10-02 projectops 업데이트로 변경 기록 워크플로가 base=main·head=deploy PR에서만 동작하게 바뀌었는데, passQL은 deploy에 직접 병합·push해 PR이 한 번도 열리지 않았다"
status: resolved
resolution: "[[ISS-0332-changelog-not-updated-on-deploy-report]]"
related: ["[[DEC-0156-projectops-release-changelog-deploy-to-main]]"]
source: "https://github.com/Twin-Fang/passQL/issues/542"
---

# ISS-0332: 배포할 때 CHANGELOG가 갱신되지 않는 문제

GitHub #542 (원본: 이슈 본문과 댓글).

## 증상
`CHANGELOG.md/json`이 2026-07-04 v0.0.190에서 멈췄다(현재 1.23.x, 버전 커밋 137개 동안 릴리즈 문서 커밋 0개). TestFlight 'What to Test'·Firebase 테스터 노트가 `v{버전} 업데이트`로 폴백한다.

## 재현 조건
main 머지 후 deploy 브랜치 push로 배포 → CHANGELOG 변화 없음.

## 조사 기록
- 2026-10-18: 원인 확인(10월 2일 이후 deploy 커밋 66개 중 PR 머지 0개), PR #545·#546으로 해결, v1.24.3 기록 확인.

## 근본 원인
2026-10-02 projectops 업데이트로 `AUTO-CHANGELOG-CONTROL`이 `RELEASE-CHANGELOG`(PR base=main, head=deploy에서만 동작)로 교체됐다. passQL은 develop 없이 main에 머지하고 deploy 브랜치 push가 배포 트리거이며 deploy에 직접 병합·push해 PR이 열리지 않아 워크플로가 동작할 기회가 없었다.
