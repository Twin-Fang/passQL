---
type: completion-report
id: ISS-0332
created: 2026-10-18
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0332-changelog-not-updated-on-deploy]]"
related: ["[[DEC-0156-projectops-release-changelog-deploy-to-main]]"]
source: "https://github.com/Twin-Fang/passQL/issues/542"
---

# ISS-0332 완료 리포트: projectops 템플릿 갱신, 릴리스 head 가드를 `deploy`로 고정, `deploy → main` 배포 PR로 CHANGELOG 기록

GitHub #542 보고 댓글 기준 (2026-10-18, PR #545, 배포 PR #546).

## 해결 방법
- `npx projectops@latest --mode workflows`로 템플릿 4.44.1 → 4.62.0 갱신(PR #545).
- 갱신이 릴리스 head 가드를 `develop`으로 되돌려 `deploy`로 다시 고정(한 줄, 이유 주석).
- `/projectops:pro-changelog-deploy`로 `deploy → main` 배포 PR 생성(PR #546). 커밋 자동 분석은 릴리스 구간에 `deploy:` 노이즈뿐이라 쓸 수 없어 7월 이후 사용자에게 보이는 변경을 주제별로 모아 노트를 직접 작성.
- 결과: main에 v1.24.3 기록(`CHANGELOG.md`, `CHANGELOG.json`). 심사용 고정 문구 설정은 변경 없음.
- 이슈 본문이 제안한 자체 워크플로 추가는 하지 않았다(결정 노트 참조).

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
- 템플릿을 다시 갱신하면 head 가드가 `develop`으로 돌아갈 수 있다. 갱신 후 `RELEASE-CHANGELOG`의 `head.ref == 'deploy'`를 확인.
- 배포 PR은 deploy를 먼저 push한 뒤 만든다(릴리스 구간 계산이 deploy 기준).
- 스토어 심사 문구는 `PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml`, `PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`의 `STORE_WHATS_NEW_OVERRIDE` 두 곳을 함께 바꾼다.
- PR #546의 `pull_request` CI 5개 실패 표시는 job 0개 — 몇 초 만에 automerge 되어 병합 ref가 사라진 것.
- 의도적으로 하지 않음: passQL이 고쳐 쓴 앱 워크플로 9개는 새 템플릿으로 덮지 않음(새 템플릿은 `.github/.projectops/incoming/`), 옛 세대 워크플로 2개 중복 실행 정리는 별도.

## 교훈
(원본에 없음, 볼트 정리) 설치 도구가 관리하는 워크플로는 업데이트 후 이 레포 고유의 브랜치 가드가 되돌아가지 않았는지 확인한다.
