---
type: completion-report
id: ISS-0107
created: 2026-04-12
topics: [practice]
status: resolved
resolves: "[[ISS-0107-execute-ui-sample-data-parsing-fix]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/191"
---

# ISS-0107 완료 리포트: 다중 행 VALUES 파싱 수정, 실행 버튼 통일, inverted 결과 테이블

GitHub #191 `## 개요` 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `client/src/components/SchemaViewer.tsx` `parseSampleData`: `VALUES` 이후 `;`까지 전체를 캡처한 뒤 `\(([^)]*)\)`로 행을 재분리. `T1: [[1],[2],[3]]`으로 파싱.
- `SqlPlayground.tsx`: `handleExecute`에 `catch` — 네트워크 오류·5xx 시 `error-card` 표시, 이전 결과 초기화. `questionUuid` prop 제거(호출부 `QuestionDetail.tsx` 포함). 헤더 `Terminal` 아이콘 + "직접 실행해보기". textarea 인라인 style → `sql-playground-textarea`. `btn-compact` → `btn-run-all`.
- `ChoiceCard.tsx`: `btn btn-xs btn-outline` → `btn-run-all`, 선택된 카드 위에서는 `btn-run-all--inverted`.
- `ResultTable.tsx`: `inverted` prop — 흰 wrapper 대신 반투명 배경(`rgba(255,255,255,0.15)`)·보더(`rgba(255,255,255,0.25)`)·흰 텍스트. `components.css`에 `result-table-meta--inverted`, `result-table-border--inverted`, `data-table--inverted` 추가.

## 근본 원인 (확정)
non-greedy 정규식이 첫 `)` 이후를 버림. 에러 경로에 `catch` 누락.

## 재발 방지
리포트 주의사항: `VALUES` 안에 중첩 괄호(함수 호출 등)가 있으면 여전히 틀릴 수 있다(현재 단순 값 목록 형식에선 문제 없음). 선택된 카드 위 `error-card`는 inverted 처리 없이 그대로 표시.

## 교훈
(원본에 없음, 볼트 정리) 스키마 샘플 데이터가 한 행만 보이거나 깨지면 `parseSampleData`의 다중 행·중첩 괄호 처리부터 본다.
