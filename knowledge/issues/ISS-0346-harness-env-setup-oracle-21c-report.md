---
type: completion-report
id: ISS-0346
created: 2026-10-21
topics: [question-bank, dev-workflow]
status: resolved
resolves: "[[ISS-0346-harness-env-setup-oracle-21c]]"
related: ["[[DEC-0163-harness-oracle-xe-21c]]"]
source: "https://github.com/Twin-Fang/passQL/issues/559"
---

# ISS-0346 완료 리포트: 검증 DB를 XE 21c로 고정, 23ai 전용 문법 점검 규칙, 환경 준비 한 번에

GitHub #559 리포트 댓글(`## 개요`, 2026-10-21) 기준.

## 해결 방법
- `tools/sqld-question-harness/sqld_harness/oracle_executor.py`: 기본 접속 `localhost:1522/XEPDB1`(XE 21c). 기존 23ai 컨테이너(1521)와 포트가 겹치지 않음. 환경변수 `SQLD_HARNESS_DSN`으로 변경 가능.
- `oracle_compatibility.py`(신규): 규칙 `compat.oracle-23ai-syntax`(warning) — GROUP BY·HAVING에서 SELECT 별칭 참조, FROM 없는 SELECT, 다중 행 VALUES, BOOLEAN, IF [NOT] EXISTS. 별칭과 같은 이름의 실제 컬럼, 인라인 뷰 별칭, 문자열 리터럴 안 키워드는 오탐하지 않음.
- `pipeline.py`: 오프라인 점검 단계에 규칙 연결. `README.md`: 준비 절차를 21c로, 21c를 쓰는 이유와 규칙 표.
- 환경 준비 절차(암호화본): 자료 준비 → 가상환경 → 21c 컨테이너 생성·시작 → 준비 완료 대기 → 테스트. `--verify-all`이면 문제 전체 재검증.

## 근본 원인 (확정)
검증 DB가 시험 기준보다 최신이었고 환경 준비가 수동이었다.

## 재발 방지
- 검증: 하네스 테스트 74개 통과(오프라인 + `--run-oracle` 21c 통합). 문제 YAML 212개 전체를 21c에서 재검증해 모두 통과. 새 규칙 전체 점검 탐지 0건.
- 주의: 새 규칙은 warning(오류를 묻는 보기라면 23ai 문법을 일부러 쓸 수 있다, 판정은 21c 검증 결과로). XE 21c 컨테이너는 약 3.3GB를 써 메모리가 부족하면 전체 재검증이 중간에 종료될 수 있다 — 묶음 단위로 `--workers 1`을 주고 앞에서 돌린다. 기존 23ai 컨테이너는 정지만 해 두었다.

## 교훈
(원본에 없음, 볼트 정리) 정답을 DB 실행으로 판정하는 검증 도구는 DB 버전을 시험 기준에 맞춰 고정해야 한다.
