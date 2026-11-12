---
type: completion-report
id: ISS-0504
created: 2026-11-12
topics: [question-bank, dev-workflow]
status: resolved
resolves: "[[ISS-0504-question-structure-audit-harness]]"
related: ["[[ISS-0502-stem-table-same-columns-overwritten]]", "[[DEC-0292-stem-table-match-by-name-short-code-caption]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1017"
---

# ISS-0504 완료 리포트: 데이터 누락 0, 하네스 lint 3개 추가, 서버 형식 검사 이름 기준

## 해결 방법
- 하네스 `table_reference_linter.py`(신규): 지문이 언급한 표 누락(error), 같은 이름 표 중복(error), 이름 다른 같은 컬럼 표(warning). `quality_linter.py` 연결, 테스트, README.
- 서버 `QuestionFormatRule`: 형식 검사·자동 정리가 `[이름]` 지문 표를 같은 이름 스키마 표와만 비교(이름 다른 같은 컬럼 표 삭제·잘못된 INSERT 이동 방지). `QuestionFormatAutoFixerTest` 사례 추가.
- 데이터 수정 없음(누락 0건). 표 소실 17건은 앱·웹 배치 수정([[ISS-0502-stem-table-same-columns-overwritten]])으로 해결, 새 파서로 499건 앱·웹 전부 통과.
- 커밋 34953299, PR #1018, 배포 PR #1019. 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1017#issuecomment-6821644341

## 근본 원인 (확정)
하네스가 지문-표 대응과 화면 배치를 검사하지 않았다. 결함은 데이터가 아니라 앱 배치 코드.

## 재발 방지
- 새 lint 3개가 생성 단계에서 막는다. 서버 형식 검사도 같은 이름 기준.
- 한계: 정규식 SQL 파서라 복잡한 SQL 참조 표를 놓칠 수 있음, 비활성 문제는 export 범위 밖이라 미조사. 운영 지문 마크다운 표 정리는 [[ISS-0480-stem-table-sql-format-data-cleanup-deferred]](보류).
- 검증: 하네스·서버 테스트 통과, 운영 배포 워크플로우 5개 성공. 실기기 검증은 하지 않음.

## 교훈
- 데이터 검수만으로는 렌더 결함을 못 잡는다. 검수 규칙은 앱·웹이 실제로 그리는 규칙과 같은 기준이어야 한다.
