---
type: issue
id: ISS-0205
created: 2026-10-07
topics: [practice]
symptoms: [코드 펜스 노출, "```sql", 지문 일반 Text, _StemSection, stemPreview, 결과 표 오른쪽 공백]
root_cause: "`question_detail_page.dart`·`chapter_page.dart`의 `_StemSection`이 지문을 일반 `Text`로만 그렸다"
status: resolved
resolution: "[[ISS-0205-stem-sql-code-fence-exposed-report]]"
related: ["[[ISS-0206-inline-code-backticks-exposed]]", "[[ISS-0214-execute-result-card-narrow]]"]
source: "https://github.com/Twin-Fang/passQL/issues/360"
---

# ISS-0205: 문제 지문의 SQL 코드 펜스(```)가 그대로 노출됨

GitHub #360 (원본: 이슈 본문과 댓글).

## 증상
문제 풀이 화면에서 지문의 SQL이 코드 블록으로 표시되지 않고 마크다운 펜스(` ```sql `, ` ``` `)가 글자 그대로 노출되며, 코드가 일반 글꼴로 줄바꿈되어 가독성이 떨어진다.

## 재현 조건
QA GitHub #357 영역 2·3(iPhone 16 Pro, 실계정): 홈 → 오늘의 세트 → 1번 문제(SQL 실행형) 지문.

## 조사 기록
- 2026-10-07: 원인 추정 — `_StemSection`이 일반 `Text`로만 그림. 홈 추천·오답 노트의 `stemPreview`에도 펜스가 섞일 수 있음.

## 근본 원인
지문 렌더링에 마크다운 코드 펜스 처리가 없었다. 결과 표는 내용 폭만큼만 그려져 카드 오른쪽이 비어 보였다(함께 수정).
