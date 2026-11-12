---
type: issue
id: ISS-0504
created: 2026-11-12
topics: [question-bank, dev-workflow]
symptoms: ["지문이 언급한 표 없음", "표 이름 중복", "이름 다른 같은 컬럼 표", "하네스 lint 누락", "table_reference_linter", "QuestionFormatRule findSchemaTableWithSameColumns", "등록 문제 구조 결함"]
root_cause: "하네스 lint에 지문 언급 표 제공 여부·표 이름 중복·이름 다른 같은 컬럼 표 검사가 없었고, 앱·웹 표 배치 규칙을 몰라 화면에서 표가 사라지는 결함을 데이터 검수로 못 걸렀다"
status: resolved
resolution: "[[ISS-0504-question-structure-audit-harness-report]]"
related: ["[[ISS-0502-stem-table-same-columns-overwritten]]", "[[ISS-0322-question-harness-restructure]]", "[[ISS-0480-stem-table-sql-format-data-cleanup-deferred]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1017"
---

# ISS-0504: 등록 문제 구조 결함 전수조사와 문제 생성·검수 하네스 보강

GitHub #1017. 원본 사본: `_sources/issues/ISS-0504-question-structure-audit-harness.md`(로컬).

## 증상
하네스로 만들고 검수해 올리는데도 등록 문제에 구조 결함이 나온다. 예: 지문이 EMP 행 수를 묻는데 EMP 표가 안 보임([[ISS-0502-stem-table-same-columns-overwritten]]).

## 재현 조건
지문 마크다운 표와 스키마 표가 둘 다 있고, 이름 다른 표의 컬럼 구성이 같은 문제.

## 조사 기록
- 2026-11-12: 운영 관리자 export(활성 499건, GET만)로 정적 전수조사. 데이터 누락 0, 앱 표 배치로 표 소실 17건(error), 이름 다른 같은 컬럼 스키마 표 25건(warning, 16건이 소실과 겹침), 복붙 의심 1건(`9f4643c9`, 지문이 "각 3행"이라 의도), 참조 표 데이터 없음 2건(풀이 가능), info 31건(대부분 오탐).
- 2026-11-12: 34953299, PR #1018, 배포 PR #1019.

## 근본 원인
lint 표 검사 4개(데이터 없는 표, 행 모양, 같은 이름 표 행 비교, 숨은 SQL)뿐. 화면 배치 시뮬레이션 없음. 서버 형식 검사도 컬럼 구성만으로 중복 지문 표를 판정.
