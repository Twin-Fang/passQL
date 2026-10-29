---
type: decision
id: DEC-0163
created: 2026-10-21
reviewed: null
topics: [question-bank, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0346-harness-env-setup-oracle-21c]]", "[[ISS-0346-harness-env-setup-oracle-21c-report]]"]
---

# DEC-0163: 문제 검증 도구의 Oracle은 XE 21c로 고정하고, 23ai 전용 문법은 warning으로 점검한다

## 문제 정의 (Context)
검증용 DB가 시험 기준(19c)보다 최신인 23ai/26ai여서, 19c에서 오류인 문법을 허용해 "오류가 나야 맞는 보기"가 다른 결과로 검증을 통과할 위험이 있었다 (GitHub #559).

## 결정 (Decision)
- 하네스 기본 접속을 `localhost:1522/XEPDB1`(Oracle XE 21c)로 고정한다. 리포트가 적은 근거: XE 21c는 "19c와 문법 동작이 같다".
- 23ai 전용 문법 5종을 찾는 규칙 `compat.oracle-23ai-syntax`를 **warning**으로 둔다. 근거(리포트): 오류가 나는 것을 묻는 보기라면 23ai 문법을 일부러 쓸 수 있고, 판정은 21c 검증 결과로 한다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (19c 자체를 쓰지 않은 이유는 원본에 적혀 있지 않다.)

## 결과 (Consequences)
**긍정**
- 문제 YAML 212개가 21c에서도 같은 정답 판정으로 통과.

**부정**
- XE 21c 컨테이너가 약 3.3GB 메모리를 써 전체 재검증이 메모리 부족으로 중단될 수 있다.

## 영향 범위 (Scope)
`tools/sqld-question-harness/sqld_harness/oracle_executor.py`, `oracle_compatibility.py`, `pipeline.py`, `README.md`, 환경 준비 절차(암호화본). `SQLD_HARNESS_DSN`으로 접속 변경 가능.

## 출처 (References)
- GitHub #559 리포트 댓글(2026-10-21)
- [[ISS-0346-harness-env-setup-oracle-21c]]
