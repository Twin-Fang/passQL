---
type: completion-report
id: ISS-0214
created: 2026-10-07
topics: [practice]
status: resolved
resolves: "[[ISS-0214-execute-result-card-narrow]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/369"
---

# ISS-0214 완료 리포트: 결과 카드 전체 폭, 표는 `LayoutBuilder`+`minWidth`로 카드 폭 채움

GitHub #369 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
`ExecuteResultCard`: `width: double.infinity`로 선택지 카드와 같은 폭. `DataTable`은 `LayoutBuilder`+`minWidth`로 카드 폭을 채우고 넘치면 가로 스크롤 유지.

## 근본 원인 (확정)
`Container`와 `DataTable`의 폭 미지정.

## 재발 방지
위젯 테스트 추가 — 수정 전 코드에서는 실패, 수정 후 통과.

## 교훈
(원본에 없음, 볼트 정리) `crossAxisAlignment: start`인 `Column` 안 카드는 폭을 명시하지 않으면 내용 폭으로 줄어든다.
