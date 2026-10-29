---
type: issue
id: ISS-0214
created: 2026-10-07
topics: [practice]
symptoms: [실행 결과 카드 폭 좁음, 표 오른쪽 공백, ExecuteResultCard, DataTable 내용 폭, "N행 반환"]
root_cause: "`ExecuteResultCard`의 `Container`가 폭을 지정하지 않아 `Column(crossAxisAlignment: start)` 안에서 내용 폭으로 줄었고, `DataTable`도 내용 폭이었다"
status: resolved
resolution: "[[ISS-0214-execute-result-card-narrow-report]]"
related: ["[[ISS-0205-stem-sql-code-fence-exposed]]"]
source: "https://github.com/Twin-Fang/passQL/issues/369"
---

# ISS-0214: SQL 실행 결과 카드가 선택지 카드보다 좁고 표 오른쪽이 빔

GitHub #369 (원본: 이슈 본문과 댓글).

## 증상
SQL 실행형 문제에서 선택지를 고르면 아래에 붙는 "N행 반환 · Nms" 실행 결과 카드의 오른쪽 끝이 선택지 카드보다 안쪽에서 끝나고, 표도 카드 폭을 채우지 못한다. GitHub #360의 결과 비교형 선택지 표 문제와 같은 계열.

## 재현 조건
QA GitHub #357 영역 4·6(iPhone 16 Pro, 실계정): 문제 탭 → JOIN 토픽 → SQL 실행형 문제에서 선택지 선택.

## 조사 기록
- 2026-10-07: 원인 확인(폭 미지정 `Container`, 내용 폭 `DataTable`).

## 근본 원인
카드와 표 모두 폭을 지정하지 않아 내용 폭으로 줄었다.
