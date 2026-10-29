---
type: issue
id: ISS-0200
created: 2026-10-07
topics: [practice]
symptoms: [RESULT_MATCH, 선택지 JSON 문자열 노출, 실행 결과형 선택지, 표 대신 JSON, ResultRowsTable]
root_cause: "앱이 결과 행 JSON 배열 선택지를 표로 그리지 않고 텍스트로 표시했다 (웹은 표로 표시)"
status: resolved
resolution: "[[ISS-0200-result-match-choices-json-string-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/355"
---

# ISS-0200: 실행 결과형 선택지가 표 대신 JSON 문자열로 표시됨

GitHub #355 (원본: 이슈 본문과 댓글).

## 증상
실행 결과를 고르는 문제(`RESULT_MATCH`)의 선택지가 앱에서 표 대신 JSON 문자열(`[{"NAME":"홍길동","SAL":5000,...}]`) 그대로 표시된다. 웹은 표로 보여 준다.

## 재현 조건
실행 결과형 문제(예: 윈도우 함수 RANK/DENSE_RANK) 열기. iOS TestFlight.

## 조사 기록
- 2026-10-07: 수정(커밋 `ffbd331`).
- 2026-10-08: main v0.5.1 기준 검증.

## 근본 원인
앱 선택지 렌더링에 결과 행 JSON을 표로 바꾸는 처리가 없었다.
