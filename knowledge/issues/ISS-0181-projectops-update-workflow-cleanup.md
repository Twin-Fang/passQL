---
type: issue
id: ISS-0181
created: 2026-10-02
topics: [ci-deploy, dev-workflow]
symptoms: [projectops, "업데이트 기준점 없음", "미커밋 워크플로우 수정 9개", ".bak 파일 10개", "--mode workflows", "Flutter 워크플로우 push 트리거 비활성"]
root_cause: "`projectops` 업데이트 기준점이 없어 업데이트 시 모든 파일을 개별 확인해야 함"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/336"
---

# ISS-0181: projectops 최신 적용 및 워크플로우 정리

GitHub #336 (원본: 이슈 본문만, 댓글 없음). GitHub 상태 closed(completed). 완료 내용은 #336 원본에 없다.

## 증상
(현재 문제점) `projectops` 업데이트 기준점이 없어 업데이트 때 모든 파일을 개별 확인해야 하고, 워크플로우 수정 9개가 미커밋, `.bak` 파일 10개가 남아 있다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-02 계획: 미커밋 변경과 `.bak` 정리 후 `--mode workflows`로 타입/경로(`flutter=app`, `react=client` 등) 지정해 업데이트, 개발 중 Flutter 워크플로우 push 트리거 비활성 유지, 업데이트 후 doctor 진단.
- 다른 이슈의 언급: GitHub #338(2026-10-07)은 "사용하지 않는 CI 워크플로우 수동 실행 전환(#336)", GitHub #339(2026-10-02)는 "항상 실패하던 CI 정리(#336)"라고 적고, `.github/workflows/*.bak` 10개는 #338에서 `.gitignore`로 추적 해제됐다.

## 근본 원인
원본에 적혀 있지 않다.
