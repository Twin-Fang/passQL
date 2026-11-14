---
type: lesson
id: LSN-0003
created: 2026-11-14
reviewed: null
topics: [question-bank, admin, ops-infra]
trigger: "운영 문제 풀을 내보내기 API로 백업할 때 (문제 수 500건 초과)"
status: active
source: "ISS-0519"
supersedes: null
superseded_by: null
related: ["[[ISS-0519-sqld-round63-trend-new-questions]]", "[[DEC-0038-question-json-roundtrip-format]]"]
---

# LSN-0003: 문제 내보내기는 1회 500건 한도라 전체 백업은 토픽별로 나눠 받는다

## 규칙
운영 문제 풀 전체를 백업할 때 내보내기를 한 번에 호출하지 말고 토픽별로 나눠 받은 뒤 합계가 운영 문제 수와 맞는지 확인한다.

## Why
내보내기는 최대 500건이다([[DEC-0038-question-json-roundtrip-format]]). #1074(63회) 반영 전 운영 문제 풀이 499건이었고 등록 후 537건이 되어, 다음부터 한 번에 받으면 일부가 빠진 백업이 된다.

## How to apply
- 반영 전 백업은 토픽별 내보내기 > 건수 합계 <-> 운영 문제 수 대조.
- 반영 후 스냅샷도 같은 방식으로 받는다.
