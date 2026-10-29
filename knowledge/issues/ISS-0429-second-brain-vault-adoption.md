---
type: issue
id: ISS-0429
created: 2026-10-29
topics: [dev-workflow]
symptoms: ["왜 이렇게 됐나", "결정 이력 회수", 세컨드 브레인, knowledge, 지식화, ingest-issue, "결정 노트"]
root_cause: "결정 이유가 GitHub 이슈·리포트 댓글에만 흩어져 있어 코드 작업 전에 에이전트가 회수할 경로가 없었다"
status: resolved
resolution: "[[ISS-0429-second-brain-vault-adoption-report]]"
related: ["[[ISS-0429-second-brain-vault-adoption-report]]", "[[DEC-0213-ingest-after-report-same-pr]]", "[[DEC-0214-no-local-design-docs-in-public-vault]]"]
source: "https://github.com/Twin-Fang/passQL/issues/751"
---

# ISS-0429: 세컨드 브레인 도입 (이슈, 리포트 지식화와 결정 기록)

GitHub #751 (원본: 이슈 본문과 리포트 댓글).

## 증상
- 코드만 봐서는 "이게 왜 이렇게 됐는지"를 알 수 없다. 이유는 GitHub 이슈와 `pro-report` 리포트 댓글에 흩어져 있다.
- 결정이 나중 이슈에서 바뀐 경우(예: 요금제 #501 > #576 > #591) 어느 것이 현재 유효한지 찾기 어렵다.

## 재현 조건
해당 없음 (도입 작업).

## 조사 기록
- 2026-10-29: 이슈 등록. 템플릿 설치, 시험 적재 5건, 원본 대조로 지어낸 문장 8곳 정정, 전체 이슈 백필(서브에이전트 배치 초안 + 직렬 번호 부여), 결정 충돌 정리(사용자 확인), 퍼블릭 레포 노출 정리, 최종 리뷰 반영.

## 근본 원인
결정 이력을 회수할 저장소가 없었다.
