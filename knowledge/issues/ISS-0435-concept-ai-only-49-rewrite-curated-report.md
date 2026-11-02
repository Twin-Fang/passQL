---
type: completion-report
id: ISS-0435
created: 2026-10-31
topics: [question-bank, ai]
status: resolved
resolves: "[[ISS-0435-concept-ai-only-49-rewrite-curated]]"
related: ["[[DEC-0228-concept-ai-only-rewritten-as-curated]]", "[[DEC-0158-new-questions-concept-only-curated]]"]
source: "https://github.com/Twin-Fang/passQL/issues/767#issuecomment-6513474980"
---

# ISS-0435 완료 리포트: AI_ONLY 개념 문제 49개 비활성화, 상황·결과형 고정 보기 문제 49개로 교체

GitHub #767 리포트 댓글 6513474980 기준 (2026-10-30). 원본 암호화본은 PR #768로 병합.

## 해결 방법
- 운영 데이터: 옛 `AI_ONLY` 개념 문제 49개 비활성화(`deactivated 49, skipped 0`, 풀이 기록 보존). 새 고정 보기 문제 49개 등록(`created 49`), 모두 `CONCEPT_ONLY` + `CURATED_ONLY`, 관리자 고정 세트 1개, 보기 4개, 정답 1개. 활성 개념 문제는 다시 261개이며 전부 고정 보기(`AI_ONLY` 0개) → [[DEC-0228-concept-ai-only-rewritten-as-curated]].
- 저장소: `docs/sqld-research-encrypted/questions/batch06a~e-concept-rewrite-*.yaml.enc` 하네스 원본 암호화본 5개.

| 묶음 | 영역 | 문제 수 | 검증 |
|---|---|---|---|
| batch06a | 서브쿼리, 조인, 계층·PIVOT | 14 | Oracle 14 |
| batch06b | 그룹 함수, 윈도우 함수 | 8 | Oracle 8 |
| batch06c | 데이터 모델링 | 8 | 개념 근거 8 |
| batch06d | DDL·DML·TCL | 10 | Oracle 6, 개념 근거 4 (그중 2개는 두 세션 실측) |
| batch06e | SELECT 기본, SQL 함수 | 9 | Oracle 9 |

- 범위형 지문은 하나도 남기지 않았다. 예: "NOT IN과 NOT EXISTS에 대한 설명으로 옳지 않은 것은?" → "최상위 관리자의 MGR이 NULL인 사원 표에서 NOT IN과 NOT EXISTS로 말단 사원을 세면?".
- 오답 3개는 각각 실제 오개념 하나(PRIOR 위치를 암기로 읽는 실수, RANGE를 ROWS로 계산하는 실수, CTAS가 PK의 NOT NULL까지 복사한다는 오해 등)를 대표하고, 보기마다 `whyPlausible`을 남겼다.
- PRIOR 문제: 같은 데이터로 `PRIOR MGR = EMPNO`(위로)와 `PRIOR EMPNO = MGR`(아래로)를 Oracle에서 모두 실행해 확인하고, 아래로 내려가는 쪽 결과를 오답 보기로 넣었다.
- 기존 고정 문제 212개와 겹치지 않게 같은 함정이 있으면 다른 핵심을 골랐고, 하네스 duplicate 규칙에도 걸리지 않았다.
- 보기마다 검증 근거를 저장. 구조화 해설(5필드)은 기존 고정 세트와 같은 방식으로 백필 스케줄러가 만든다(10분마다 6세트).

검증: 하네스 lint 새 파일 error 0건(warning 1건 b06a_12는 숫자 보기 중 12만 두 자리라 생긴 길이 경고, 정답 단서 아님). Oracle 21c verify 49/49, 보기 196개 판정 모두 맞음. 운영 관리자 가져오기 검증 49/49, 등록 created 49. 운영 DB에서 새 49개 모두 `CURATED_ONLY`·고정 세트 1개·보기 4개·정답 1개 확인. 관리자 문제 상세 화면에서 지문·표·SQL·보기·보기별 해설 표시 확인.

## 근본 원인 (확정)
`AI_ONLY` 보기 정책과 범위형 지문.

## 재발 방지
리포트의 주의사항:
- 개념 문제 AI 보기 경로는 코드에 남아 있다. 관리자가 `AI_ONLY`로 새 개념 문제를 등록하면 같은 문제가 다시 생길 수 있다. 등록 화면에서 개념형 + `AI_ONLY` 조합을 막을지는 별도 결정이 필요하다(미결).
- 구조화 해설은 등록 직후 49세트 모두 비어 있고 백필 스케줄러가 약 90분 안에 채운다. 그 전에 열면 보기별 검증 근거가 먼저 보이고 생성이 시작된다.
- 이론형 12문제는 Oracle로 실행할 수 없어 개념 근거(`content/concepts/data_modeling`, `sql_ddl_dml_tcl` 개념 파일과 SQLD 가이드)로 검토했다.
- 원본 평문은 `docs/sqld-research/questions/`(로컬, gitignore). 수정은 평문을 고친 뒤 `scripts/research-docs-crypt.sh encrypt`로 암호화본을 다시 만든다.

## 교훈
논의 기록 없음.
