# SQLD 고정 보기 문제 검증 하네스 (#511)

문제 원본 YAML(`docs/sqld-research/questions/`, 로컬 원문·커밋은 암호화본) > Oracle Free 실행 > 보기 기대값 대조 > 통과분만 관리자 가져오기 JSON.

## 실행
1. Oracle: `docker run -d --name sqld-harness-oracle -p 1521:1521 -e ORACLE_PASSWORD=harness gvenzl/oracle-free:23-slim-faststart` (로그 `DATABASE IS READY TO USE` 대기)
2. 의존성: `python3 -m venv .venv && .venv/bin/pip install oracledb pyyaml`
3. 검증: `.venv/bin/python -I harness.py verify ../../docs/sqld-research/questions --output import.json`
4. 등록: 관리자 문제 관리 > JSON 가져오기(검증 > 성공 항목만 등록)

## 문제 YAML
`harness.py` 머리 주석의 expect 6종(rows, scalar, same_as_answer, error, body_rows, count + pick, concept) 참고.
정답 보기는 expect 참, 오답 보기는 rows·scalar 불일치 / 나머지 expect 는 사실이어야 통과.
출력 JSON 은 `executionMode=CONCEPT_ONLY`, `choiceSetPolicy=CURATED_ONLY` (운영 샌드박스는 PostgreSQL 이라 Oracle 기준 문제는 실행 대상 아님).
