---
type: completion-report
id: ISS-0200
created: 2026-10-07
topics: [practice]
status: resolved
resolves: "[[ISS-0200-result-match-choices-json-string]]"
related: ["[[ISS-0205-stem-sql-code-fence-exposed]]"]
source: "https://github.com/Twin-Fang/passQL/issues/355"
---

# ISS-0200 완료 리포트: 결과 행 JSON 선택지를 `ResultRowsTable` 표로 표시

GitHub #355 댓글 기준 (커밋 `ffbd331`, 2026-10-07 / 검증 2026-10-08). `## 개요` 형식 리포트는 없음.

## 해결 방법
선택지 본문이 결과 행 JSON 배열(`[{"COL": 값}]`)이면 열 이름 헤더와 행으로 된 표(`ResultRowsTable`)로 표시, 열이 많으면 가로 스크롤. 일반 텍스트·SQL 선택지는 그대로.

## 근본 원인 (확정)
앱에 결과 행 표 렌더링이 없었다.

## 재발 방지
위젯 테스트 `choice_card_test.dart`(결과 행 JSON 배열만 표 데이터로 인식 — 일반 텍스트·SQL·잘못된 JSON은 제외 / 표 렌더링). 앱 전체 테스트 169건, 정적 분석 0건. 실기기(TestFlight) 재확인은 하지 않았다.

## 교훈
(원본에 없음, 볼트 정리) 웹과 앱이 같은 선택지를 다르게 그리면, 선택지 본문 형식별 렌더링 분기가 한쪽에만 있는지 본다.
