# SQLD 고정 보기 문제 하네스 v2 (#511 > #524)

문제 YAML 한 벌로 **출제 경향 근거 > 문제 초안 > Oracle 실행 검증 > 품질 점검 > 해설 초안 > 등록 JSON·리포트**까지 처리한다.
문제 원본은 `docs/sqld-research/questions/`(로컬 원문, gitignore)이고, 커밋하는 것은 암호화본(`docs/sqld-research-encrypted/`)뿐이다.

```
(a) 경향 근거     trend_catalog.py      trend.templates·examRounds·isLatestTrend 검증, 템플릿 커버리지
(b) 초안 구조     question_schema.py    YAML v1·v2 로드, 구조 규칙 (보기 4개·정답 1개·v2 필수 메타)
(c) Oracle 검증   oracle_executor.py    문제별 임시 스키마 (스레드별 관리자 연결)
                  choice_verifier.py    보기 expect 판정, pick max|min
                  verification_runner.py 캐시 조회 > 미스분만 병렬 실행
(d) 품질 점검     quality_linter.py     함정 타당성·길이 균형·지문 체크리스트·표<->데이터·정답 위치 분포
                  duplicate_detector.py 묶음 안·기존 풀 대비 중복
(e) 해설 초안     explanation_hook.py   #521 구조화 해설 5필드 초안 + 검증 (생성기 교체 가능)
(f) 등록·리포트   import_exporter.py    관리자 가져오기 JSON (v1 과 같은 모양) + v2 메타 파일
                  report_markdown.py / report_html.py / question_statistics.py
조립              pipeline.py, harness.py (CLI)
```

## 준비
1. 원문 복호화: `bash scripts/research-docs-crypt.sh decrypt` (키: 루트 `.env` 의 `RESEARCH_DOCS_ENCRYPTION_KEY`)
2. 의존성: `cd tools/sqld-question-harness && python3 -m venv .venv && .venv/bin/pip install oracledb pyyaml pytest`
3. Oracle (verify 만 필요): `docker run -d --name sqld-harness-oracle -p 1521:1521 -e ORACLE_PASSWORD=harness gvenzl/oracle-free:23-slim-faststart` (로그 `DATABASE IS READY TO USE` 대기)
   - 접속값 환경변수: `SQLD_HARNESS_DSN`, `SQLD_HARNESS_ADMIN_USER`, `SQLD_HARNESS_ADMIN_PASSWORD`

## 명령
| 명령 | Oracle | 하는 일 |
| --- | --- | --- |
| `verify <경로> [--output import.json] [--metadata meta.json] [--results results.json] [--workers 4] [--no-cache]` | 필요 | 전 단계 실행 > 차단 finding 없고 Oracle 통과한 문제만 가져오기 JSON |
| `render <경로>` | - | 지문·보기 미리보기 (v1 그대로) |
| `lint <경로> [--against pool.json] [--strict] [--verbose]` | - | 구조·경향·품질·중복·해설 점검. error 있으면 종료코드 1 (`--strict` 는 warning 도) |
| `stats <경로> [--json]` | - | 토픽·난이도·정답 위치·expect·최신 경향·템플릿 공백·결과 추적형 비율 |
| `report <경로> [--results results.json] [--md report.md] [--html report.html]` | - | 리포트 (verify `--results` 를 넘기면 Oracle 결과 포함) |
| `explain <경로> [--output explanations.json]` | - | 해설 초안(#521 5필드) 생성·검증 |
| `scaffold [--id 문제_id]` | - | YAML v2 빈 양식 출력 |

공통 옵션: `--trend-catalog` (기본 `docs/sqld-research/trend-catalog.yaml`, 없으면 템플릿 검증 생략), `--against` (관리자 내보내기 JSON 과 중복 비교).

예시 흐름:
```bash
H=tools/sqld-question-harness; Q=docs/sqld-research/questions
$H/.venv/bin/python -I $H/harness.py scaffold --id b04_new > $Q/batch04.yaml   # 양식에서 시작
$H/.venv/bin/python -I $H/harness.py lint $Q                                   # Oracle 없이 먼저
$H/.venv/bin/python -I $H/harness.py verify $Q --output import.json --metadata meta.json --results results.json
$H/.venv/bin/python -I $H/harness.py report $Q --results results.json --html report.html
```
등록: 관리자 문제 관리 > JSON 가져오기 (검증 > 성공 항목만 등록). 가져오기 JSON 은 `executionMode=CONCEPT_ONLY`, `choiceSetPolicy=CURATED_ONLY` (운영 샌드박스는 PostgreSQL 이라 Oracle 기준 문제는 실행 대상 아님).
v2 메타(경향·개념·해설 초안)는 서버 DTO 가 아직 받지 않아 `--metadata` 별도 파일로만 낸다.

## 문제 YAML v2 스키마
v1 문제(`schemaVersion` 없음)는 그대로 동작한다. v2 는 `schemaVersion: 2` 를 쓰고 아래 ★ 필드가 필수다. 전체 예시는 `harness.py scaffold`.

| 필드 | 필수 | 뜻 |
| --- | --- | --- |
| `id` | 권장 | 문제 식별자 (없으면 `{파일명}_{순번}`), 묶음 안 중복 금지 |
| `topicCode`, `difficulty` | 필수 | 서버 토픽 코드, 1~5 |
| `trend.templates` | v2 권장 | 경향 카탈로그 템플릿 id (`T01`~) |
| `trend.examRounds` | 선택 | 근거 회차 목록 |
| `trend.isLatestTrend` | 선택 | 학습 화면 "최신 경향" 표시. true 면 카탈로그 `latestExamRounds` 중 하나가 examRounds 에 있어야 함 |
| `intent` | 권장 | 출제 의도 한 줄 |
| `trapDesign` ★ | v2 | 꼬는 포인트 (어디서 학습자가 걸리는가) |
| `difficultyReason` ★ | v2 | 난이도 근거 (결합 개념 수, 추적 단계 수) |
| `concepts` ★ | v2 | 개념 태그 목록 (2~3개 결합 권장) |
| `stem` | 필수 | 지문 |
| `tables` | 결과형 권장 | 지문에 보일 표 `{name, columns, rows: [[...]]}` — 행은 반드시 리스트 |
| `displaySql` | 결과형 권장 | 지문에 보일 SQL |
| `ddl`, `data`, `answerSql` | 실행형 | Oracle 실행 근거 |
| `pick` | 선택 | `max`/`min`: count 보기 중 정답이 유일한 최대·최소 |
| `sourceNote` | 개념형 필수 | 근거 출처 |
| `hint` | 선택 | 힌트 (해설 examTip 기본값) |
| `choices[].body` / `kind` / `isCorrect` / `rationale` / `expect` | 필수 | 보기 4개, 정답 1개 |
| `choices[].whyPlausible` ★ | v2 오답 | 학습자가 이 오답을 고르는 이유 (8자 이상) |
| `explanation` | 선택 | `correctReason`, `keyConcepts`, `confusingPoints`, `choiceAnalysis`, `examTip` 직접 작성분 (없는 필드는 초안 조립) |

### 보기 expect (보기마다 1개)
| expect | 비교 대상 | 정답 보기 | 오답 보기 |
| --- | --- | --- | --- |
| `rows: [[...]]` (`ordered: false` 가능) | 정답 SQL 결과 행 | 일치 | 불일치 |
| `scalar: 값` | 정답 SQL 1행 1열 | 일치 | 불일치 |
| `same_as_answer: true\|false` | 보기 SQL 결과 = 정답 결과? | 사실 | 사실 |
| `error: true\|false` | 보기 SQL 오류 여부 | 사실 | 사실 |
| `body_rows: [[...]]` | 보기 SQL 결과 자체 | 사실 | 사실 |
| `count: n` | 보기 SQL 결과 행 수 (`pick` 과 함께) | 사실 | 사실 |
| `concept: true` | 실행 불가 설명형 (sourceNote 필수) | 수동 검토 | 수동 검토 |

보기 SQL 은 보기마다 초기 데이터로 되돌린 뒤 실행한다.

## 품질 기준 (lint 규칙)
심각도: **error** = 등록 차단, **warning** = 검토 필요, **info** = 경향 권장.

| 규칙 | 심각도 | 기준 |
| --- | --- | --- |
| `structure.*` | error (토픽은 warning) | 보기 4개, 정답 1개, 본문·근거·expect, 개념형 sourceNote, rows·scalar·same_as_answer 는 answerSql, 난이도 1~5, id 중복 |
| `v2.*` | error | v2 는 trapDesign·difficultyReason·concepts 필수 |
| `trap.why-plausible` | v2 error / v1 info | 오답마다 whyPlausible. 8자 미만은 warning |
| `balance.correct-longest` | warning | 정답 보기가 유일하게 가장 길고 오답 평균의 1.6배 이상 |
| `balance.numeric-order` | info | 숫자 보기는 오름차순 배치 |
| `stem.question-form`, `stem.selection-criterion` | warning | 질문형 끝맺음, 고르는 기준 단어 (옳은/옳지 않은/가장/결과/오류 등) |
| `stem.data-hidden`, `stem.sql-hidden` | warning | data 는 있는데 tables 없음, answerSql 은 있는데 displaySql·SQL 보기 없음 |
| `data.table-shape` | error | 표 행이 리스트가 아니거나 컬럼 수 불일치 (문자열 행은 글자 단위로 쪼개져 렌더링됨) |
| `data.table-mismatch` | error | 지문 표와 실제 INSERT 데이터 불일치 (단순 `INSERT INTO t VALUES (...)` 만 비교) |
| `expect.order-dependent` | warning | ORDER BY 없는 결과를 순서 있는 rows 로 비교 |
| `distribution.answer-position` | warning | 8문항 이상에서 한 정답 위치가 40% 초과 |
| `duplicate.identical` / `duplicate.similar` | error / warning | 같은 정답 SQL·보기 / 정규화 유사도 0.9 이상 (묶음 안, `--against` 기존 풀) |
| `trend.*` | error·warning·info | 카탈로그에 없는 템플릿, 최신 경향 근거 회차 없음, v2 템플릿 누락, 최신 회차 근거인데 플래그 없음 |
| `explanation.*` | error·warning·info | correctReason·choiceAnalysis(A~D, 정답 표시 일치) 필수, keyConcepts 1~5개, 짧은 정답 값은 correctReason 에 언급 |
| `trend.concept-combination` | info | v2 concepts 1개 (2026 경향: 2~3개 결합) |

임계값은 `sqld_harness/constants.py` 한 곳에서 관리한다.
정답 위치 분포는 원본 YAML 기준 참고값이다. CURATED_ONLY 세트는 풀이 응답마다 보기 순서를 섞어 실제 노출 위치는 무작위라 쏠림 경고가 나와도 재배치는 필요 없다.

## 캐시·병렬
- 캐시 키: ddl·data·answerSql·pick·보기(body·isCorrect·expect) + 검증 규칙 버전. 지문·근거·태그·해설 수정은 Oracle 재실행 없음.
- 기본 위치 `.cache/verify-cache.json` (gitignore), `--no-cache` 로 끔. 하네스·연결 오류 결과는 저장하지 않음.
- 문제별 스키마 이름 `SQLDQ_{id 앞 17자}_{해시 6자}` 라 병렬 실행 시 충돌 없음.

## 해설 생성기 교체 (#521 연결 지점)
`explanation_hook.ExplanationDrafter` 는 `draft(question) > dict(5필드)` 하나만 요구한다. 기본 `FieldExplanationDrafter` 는 YAML 필드를 조립하고,
LLM 생성기를 붙일 때는 같은 모양의 클래스를 `pipeline.run_offline_checks(..., explanation_drafter=...)` 에 넘긴다. 검증(`find_explanation_findings`)은 생성기와 무관하게 같은 규칙을 적용한다.

## 테스트
```bash
cd tools/sqld-question-harness
.venv/bin/python -m pytest -q               # 오프라인 (SQLite 대역 실행기로 검증 로직 포함)
.venv/bin/python -m pytest -q --run-oracle  # Oracle 컨테이너 통합 테스트 포함
```
