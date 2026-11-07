---
type: decision
id: DEC-0279
created: 2026-11-07
reviewed: null
topics: [question-bank, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0480-stem-table-sql-format-data-cleanup-deferred]]", "[[ISS-0474-question-format-rule-forbidden-punctuation-report]]", "[[DEC-0277-no-dash-middle-dot-server-cleaner]]", "[[DEC-0278-stem-blocks-single-table-shape]]"]
---

# DEC-0279: 운영 문항의 지문 표 자동 정리(스키마와 같은 지문 표 삭제, 지문 표 > 스키마 표)는 #903 앱이 두 스토어에 나오고 최소 지원 버전을 그 버전으로 올린 뒤에 적용한다

## 문제 정의 (Context)
#905([[ISS-0474-question-format-rule-forbidden-punctuation]]) 배포 뒤 운영 순서는 관리자 「문제 형식 검사」에서 자동 정리를 선택 적용하는 것이었다. 미리보기 대상 273문제가 전부 개념형(`CONCEPT_ONLY`)이었고, #903 이전 앱은 풀이 화면에서 스키마 표를 실행형에만 그린다. 지금 지우면 옛 앱 사용자(iOS 1.83.0 심사 중이라 대부분)에게 표가 사라져 문제를 풀 수 없다 (GitHub #905 운영 실측 댓글, #923).

## 결정 (Decision)
- 순서: #903 들어간 앱 버전이 iOS, Android 스토어에 모두 출시 > 앱 최소 지원 버전(강제 업데이트)을 그 버전으로 상향 > 관리자 「문제 형식 검사」 미리보기 > 선택 적용 > 앱과 웹에서 개념형 문제 표가 지문 카드 안에 한 번 나오는지 캡처.
- 그 전까지 운영 데이터의 지문 표는 그대로 둔다. 화면 중복은 새 앱과 웹이 그릴 때 이미 막는다([[DEC-0278-stem-blocks-single-table-shape]]).
- SQL 안 한글 주석 20건은 규칙(라벨 줄 허용 범위)을 먼저 다시 정하고 손으로 정리한다. SELECT 줄바꿈 69건은 정답 판정에 영향 없는 줄바꿈만 손으로.
- 결정 주체: 작업 중 판단(#905 운영 적용 단계), 사용자 확인 기록 없음.

## 검토한 대안 (Alternatives)
- 지금 바로 선택 적용: 옛 앱에서 개념형 273문제의 표가 사라져 보류 (#905 운영 실측 댓글).
- 그 밖의 대안 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 옛 앱 사용자도 표를 계속 보고 문제를 풀 수 있다.

**부정 / 조건**
- 최소 버전 상향 전까지 운영 데이터는 [[DEC-0277-no-dash-middle-dot-server-cleaner]]의 "데이터 표는 스키마 표 한 곳" 규칙을 어긴 상태로 남는다(새 문항은 등록 규칙이 막음).
- 관리자 「문제 형식 검사」 위반 건수가 그동안 줄지 않는다.

## 영향 범위 (Scope)
운영 DB `question` 지문과 스키마 칸, 관리자 `/admin/question-format` 자동 정리 적용 시점, 앱 최소 지원 버전 설정.

## 출처 (References)
- GitHub #905 운영 실측 댓글(2026-11-07, 「표 정리를 보류한 이유」), GitHub #923 이슈 본문
- W4 충돌 검사:
  - [[DEC-0277-no-dash-middle-dot-server-cleaner]]: 규칙(데이터 표는 스키마 표 한 곳)은 그대로이고 기존 데이터 적용 시점만 정해 충돌 없음.
  - [[DEC-0278-stem-blocks-single-table-shape]]: 그리기 규칙과 독립, 충돌 없음.
