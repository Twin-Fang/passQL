---
type: issue
id: ISS-0337
created: 2026-10-20
topics: [practice]
symptoms: [NULL, "빈칸", "결과형 보기", "빈 문자열 구분 불가", result_rows_table.dart, ResultMatchTable.tsx, "AI 해설 불일치"]
root_cause: "앱 result_rows_table.dart와 웹 ResultMatchTable.tsx가 null을 빈 문자열로 바꿔 그렸다"
status: resolved
resolution: "[[ISS-0337-result-choice-null-shown-blank-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/549"
---

# ISS-0337: 결과형 보기에서 NULL 값이 빈칸으로 표시

GitHub #549 (원본: 이슈 본문과 댓글).

## 증상
결과형 보기(실행 결과 표를 고르는 문제)에서 NULL이 빈칸으로 그려져 NULL과 빈 문자열을 구분할 수 없다. 같은 화면의 스키마 표·실행 결과 카드는 `NULL`로 표시해 표기가 엇갈린다. AI 해설은 "NULL 로 표시된다"고 설명해 화면과 어긋난다.

## 재현 조건
앱 홈 > 오늘의 세트(2026-10-20) > 2번 문제(스칼라 서브쿼리, 매칭 행 없음 > NULL) > 보기 A 결과 표에서 NULL이어야 할 칸이 빈칸. iOS 18.3 시뮬레이터, 앱 debug 빌드(main 0e2fda60), 운영 서버. 웹은 코드 확인만.

## 조사 기록
- 2026-10-20: 원인 위치 확인 — 앱 `app/lib/presentation/widgets/question/result_rows_table.dart:118`, 웹 `client/src/components/ResultMatchTable.tsx:63`.

## 근본 원인
앱·웹 표 컴포넌트가 null을 빈 문자열로 바꿔 그렸고, NULL 표기가 앱 3곳·웹 3곳에 흩어져 있었다.
