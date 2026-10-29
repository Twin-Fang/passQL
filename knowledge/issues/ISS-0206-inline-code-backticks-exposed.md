---
type: issue
id: ISS-0206
created: 2026-10-07
topics: [practice]
symptoms: [인라인 백틱 노출, "`PIVOT`", 지문 카드 폭 불일치, InlineCodeText, 선택지 백틱]
root_cause: "지문·선택지에 인라인 코드(백틱) 처리가 없었다 — #360(코드 펜스)과 같은 계열"
status: resolved
resolution: "[[ISS-0206-inline-code-backticks-exposed-report]]"
related: ["[[ISS-0205-stem-sql-code-fence-exposed]]"]
source: "https://github.com/Twin-Fang/passQL/issues/361"
---

# ISS-0206: 문제 지문·선택지의 인라인 코드 백틱(`)이 그대로 노출됨

GitHub #361 (원본: 이슈 본문과 댓글).

## 증상
문제 지문·선택지의 인라인 코드 표기(`` `PIVOT` ``)가 백틱 글자 그대로 노출된다.

## 재현 조건
QA GitHub #357 영역 3·4(iPhone 16 Pro, 실계정): 홈 → 오늘의 세트 → 2번(개념 문제) 지문 "`PIVOT`과 `UNPIVOT`에 대한 설명 중 옳지 않은 것은?".

## 조사 기록
- 2026-10-07: GitHub #360(코드 펜스)과 같은 계열이지만 인라인 코드 처리가 따로 필요하다고 판단.

## 근본 원인
인라인 코드 렌더링이 없었다. 지문 카드가 글 길이만큼만 줄어 선택지 카드보다 좁던 문제도 함께 있었다.
