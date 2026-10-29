---
type: issue
id: ISS-0288
created: 2026-10-15
topics: [practice]
symptoms: [SQL 실행 실패 미표시, "로딩만 끝남", SANDBOX_TIMEOUT, "제출에 실패했어요", "catch 후 null 반환", 409, 5xx]
root_cause: "SQL 실행 API 실패 시 결과 카드 없이 로딩만 끝났고, 제출 실패를 catch 후 null로 돌려줘 원인과 무관한 같은 문구만 띄웠다"
status: resolved
resolution: "[[ISS-0288-sql-execute-failure-not-shown-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/482"
---

# ISS-0288: 앱에서 SQL 실행 실패가 표시되지 않고 제출 실패 문구가 원인과 무관

GitHub #482 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- 실행 API가 네트워크 오류, 5xx, `SANDBOX_TIMEOUT`으로 실패하면 결과 카드 없이 로딩만 끝남.
- 제출 실패는 catch 후 null 반환이라 네트워크, 5xx, 409를 구분하지 않고 같은 문구("제출에 실패했어요", 2곳).
- 위치: `app/lib/presentation/providers/question_providers.dart:218-221,245-249`, `pages/questions/chapter_page.dart:90`, `pages/questions/question_detail_page.dart:91`.

## 재현 조건
SQL 실행 또는 제출 요청이 네트워크 오류·5xx·타임아웃·409로 실패할 때.

## 조사 기록
- 2026-10-15: 예상 동작 — 실행 실패 시 오류 카드와 다시 시도 버튼, 원인별 문구(ErrorCode 매핑), 제출은 `AppException`을 돌려줘 원인별 문구.

## 근본 원인
frontmatter `root_cause`와 같음.
