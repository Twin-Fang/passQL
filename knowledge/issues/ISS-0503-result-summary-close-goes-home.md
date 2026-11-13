---
type: issue
id: ISS-0503
created: 2026-11-12
topics: [practice]
symptoms: ["닫기 누르면 홈으로", "세트 결과로 안 돌아감", "다시 풀기 후 닫기", "leaveSolvingFlow", "solving_flow_exit.dart", "결과 요약 위 문제"]
root_cause: "leaveSolvingFlow가 맨 위부터 이어진 풀이 흐름 화면(세트·세트 결과·문제·채점 결과)을 전부 닫아, 결과 요약 위에서 연 문제를 닫아도 요약까지 함께 닫혔다"
status: resolved
resolution: "[[ISS-0503-result-summary-close-goes-home-report]]"
related: ["[[ISS-0356-home-questions-tab-restructure]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1016"
---

# ISS-0503: 세트 결과에서 연 문제를 닫으면 결과가 아니라 홈으로 감

GitHub #1016. 원본 사본: `_sources/issues/ISS-0503-result-summary-close-goes-home.md`(로컬). `leaveSolvingFlow`는 [[ISS-0356-home-questions-tab-restructure]]에서 도입.

## 증상
오늘의 세트 결과에서 틀린 문제를 "다시" 풀고 채점 결과(해설)에서 "닫기"를 누르면 세트 결과가 아니라 홈으로 감.

## 재현 조건
1. 오늘의 세트를 끝낸다. 2. 결과에서 틀린 문제 "다시". 3. 정답을 고르고 채점 결과에서 "닫기".

## 조사 기록
- 2026-11-12: `solving_flow_exit.dart` 수정, #999 커밋 16f8844b에 포함. PR #1018, 배포 PR #1019.

## 근본 원인
흐름 나가기가 결과 요약 화면을 멈춤 지점으로 보지 않았다.
