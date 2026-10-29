---
type: issue
id: ISS-0255
created: 2026-10-10
topics: [ci-deploy, dev-workflow]
symptoms: [projectops 4.40.0, 템플릿 업데이트, 범용 워크플로 재생성]
root_cause: "설치된 projectops 템플릿이 4.40.0이고 최신은 4.44.1이었다"
status: resolved
resolution: "[[ISS-0255-projectops-4-44-1-update-report]]"
related: ["[[ISS-0254-projectops-4-40-play-closed-testing]]"]
source: "https://github.com/Twin-Fang/passQL/issues/449"
---

# ISS-0255: projectops 템플릿 4.40.0 → 4.44.1 업데이트

GitHub #449 (원본: 이슈 본문과 완료 보고 댓글).

## 증상
passQL에 설치된 projectops 템플릿이 4.40.0이고 최신은 4.44.1.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-10: 요구 — passQL용으로 고쳐 쓴 워크플로는 덮어쓰지 않음, 이전에 지운 범용 워크플로가 다시 생기지 않게, 업데이트 후 구문·doctor 확인.

## 근본 원인
해당 없음 (버전 업데이트).
