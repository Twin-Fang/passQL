---
type: lesson
id: LSN-0005
created: 2026-11-16
reviewed: null
topics: [question-bank, admin, ops-infra]
trigger: "운영 문제 등록 전 기존 문항 수·중복 여부를 관리자 내보내기 API 로 집계할 때 (운영 문제 500건 초과)"
status: active
source: "ISS-0535"
supersedes: null
superseded_by: null
related: ["[[ISS-0535-past-exam-restored-rounds]]", "[[LSN-0003-question-export-500-limit-backup-by-topic]]", "[[DEC-0324-question-internal-tag-namespace-format]]"]
---

# LSN-0005: 내보내기 API 는 한 번에 500건까지라, 등록 전 중복·건수 집계도 토픽·난이도로 나눠 받아 합계를 운영 수와 맞춘 뒤 판단한다

## 규칙
운영 관리자 문항 내보내기 결과로 "이미 등록됐는지·몇 건인지"를 판단하기 전에, 토픽·난이도로 나눠 받아 합계가 운영 문제 수와 같은지 확인한다. 합계가 안 맞으면 그 집계로 등록·중복 판단을 하지 않는다.

## Why
#1079(기출 복원) 운영 등록 때 내보내기를 한 번에 받아 집계했는데 500개에서 잘려, 이미 들어간 52회 20문항을 없는 것으로 보고 다시 등록했다(중복분은 비활성화로 정리). [[LSN-0003-question-export-500-limit-backup-by-topic]]은 백업 상황만 다뤘고, 같은 상한이 중복 판단 집계에서도 사고를 냈다.

## How to apply
- 등록 전 기존 문항 확인은 토픽별(한 토픽이 500건을 넘으면 난이도까지) 내보내기 > 합계 <-> 운영 문제 수 대조.
- 회차·출처 단위 확인은 가능하면 내보내기 대신 내부 태그 필터(`round:52`, `source:52-*`, [[DEC-0324-question-internal-tag-namespace-format]])로 한다.
- 등록 뒤 회차별 건수(50/50)를 다시 세어 중복을 잡는다.
