---
type: completion-report
id: ISS-0503
created: 2026-11-12
topics: [practice]
status: resolved
resolves: "[[ISS-0503-result-summary-close-goes-home]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/1016"
---

# ISS-0503 완료 리포트: 결과 요약 위에서 연 문제를 닫으면 요약에서 멈춤

## 해결 방법
- `app/lib/router/solving_flow_exit.dart`: 결과 요약 경로 집합(세트 결과, 랜덤 요약, 챕터 결과) 추가. 맨 위부터 흐름 화면을 셀 때 맨 위가 아닌 결과 요약을 만나면 멈추고 그 위만 pop. 요약 자체를 닫으면 기존대로 흐름 시작 전 화면(없으면 홈).
- 커밋 16f8844b(#999 커밋에 포함), PR #1018, 배포 PR #1019. 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1016#issuecomment-6821643987

## 근본 원인 (확정)
`leaveSolvingFlow`가 연속된 흐름 화면을 전부 세어 결과 요약까지 닫았다.

## 재발 방지
- 새 결과 요약 화면을 만들면 `_solvingFlowRoutePaths`와 `_resultSummaryRoutePaths` 두 집합에 함께 넣는다.
- 검증: 운영 배포 워크플로우 5개 성공. 실기기 검증은 하지 않음.

## 교훈
- "닫기"가 엉뚱한 곳으로 가면 흐름 경로 집합과 스택을 먼저 본다.
