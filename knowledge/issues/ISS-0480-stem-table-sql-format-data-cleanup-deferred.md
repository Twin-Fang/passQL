---
type: issue
id: ISS-0480
created: 2026-11-07
topics: [question-bank, admin]
symptoms: ["스키마 표와 같은 지문 표 354", "스키마 밖 데이터 표 18", "SELECT 목록 한 줄 초과 69", "SQL 안 한글 주석 20", "옛 앱 개념형 스키마 표 안 그림", "문제 형식 검사 자동 정리 보류"]
root_cause: "자동 정리 대상 273문제가 전부 개념형이고 #903 이전 앱은 스키마 표를 실행형에만 그려, 지문 표를 지금 지우면 옛 앱에서 표가 사라진다"
status: open
resolution: null
related: ["[[ISS-0474-question-format-rule-forbidden-punctuation]]", "[[ISS-0472-stem-readability-blocks-single-table]]", "[[DEC-0279-stem-table-data-cleanup-after-min-version]]", "[[DEC-0278-stem-blocks-single-table-shape]]", "[[DEC-0277-no-dash-middle-dot-server-cleaner]]"]
source: "https://github.com/Twin-Fang/passQL/issues/923"
---

# ISS-0480: 지문 중복 표와 SQL 서식 운영 데이터 정리 (#903 앱 보급 후)

GitHub #923 (https://github.com/Twin-Fang/passQL/issues/923). #905([[ISS-0474-question-format-rule-forbidden-punctuation]]) 운영 적용 단계에서 나눈 후속 이슈. 원본 사본: `_sources/issues/ISS-0480-stem-table-sql-format-data-cleanup-deferred.md`(로컬).

## 증상
2026-11-07 관리자 「문제 형식 검사」 기준 (줄표, 가운뎃점은 0건):

| 사유 | 건수 | 자동 |
|---|---|---|
| 스키마 표와 같은 지문 표 | 354 | 354 |
| 스키마 밖 데이터 표 | 18 | 13 |
| SELECT 목록 한 줄 초과 | 69 | 손으로 |
| SQL 안 한글 주석 | 20 | 손으로 |

## 재현 조건
관리자 `/admin/question-format` 미리보기: 대상 273문제(스키마와 같은 지문 표 삭제 272, 지문 표 > 스키마 표 7) 모두 실행 모드 `CONCEPT_ONLY`.

## 조사 기록
- 2026-11-07: #903 이전 앱 풀이 화면은 스키마 표를 실행형(`EXECUTABLE`)에만 그린다(옛 `question_solving_body.dart`). 모의고사 화면은 스키마 표가 있으면 그린다. 지금 지문 표를 지우면 옛 앱에서 개념형 문제의 표가 사라진다. iOS 1.83.0 심사 중이라 사용자 대부분이 옛 앱.
- 새 앱과 웹(#903, [[DEC-0278-stem-blocks-single-table-shape]])은 같은 컬럼의 지문 표를 스키마 표로 바꿔 한 번만 그리므로 화면 중복은 이미 없다.
- 손으로 할 항목: 한글 주석 20건은 대부분 `-- ① A 접속` 같은 순서 실행 문제의 단계 라벨이라 코드 밖으로 빼면 오히려 읽기 어렵다(라벨 줄 허용 범위 재검토 필요). SELECT 줄바꿈 69건은 정답 판정에 영향 없는 줄바꿈만.
- 앱에 강제 업데이트(최소 지원 버전) 화면이 있다(`force_update_page.dart`).
- 처리 순서: [[DEC-0279-stem-table-data-cleanup-after-min-version]].

## 근본 원인
frontmatter `root_cause`와 같음 (데이터 정리가 옛 클라이언트 표시 규칙에 기대는 상태).
