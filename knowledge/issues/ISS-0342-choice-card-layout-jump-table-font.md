---
type: issue
id: ISS-0342
created: 2026-10-20
topics: [practice, design-system]
symptoms: ["레이아웃 점프", "채점 아이콘", passql_choice_card.dart, JetBrainsMono, "한글 공백 넓음", "인라인 코드 줄바꿈", "GROUP BY 갈라짐", "제목 중복", "오늘의 세트"]
root_cause: "채점 순간 아이콘이 붙어 보기 폭이 줄었고, 결과 표 셀이 고정폭 글꼴이라 한글 공백이 벌어지는 등 공통 위젯의 작은 시각 결함 묶음"
status: resolved
resolution: "[[ISS-0342-choice-card-layout-jump-table-font-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/554"
---

# ISS-0342: 채점 후 보기 카드 레이아웃 점프와 결과 표 글꼴 다듬기

GitHub #554 (원본: 이슈 본문과 댓글).

## 증상
풀이 화면 낮은 우선순위 시각 결함 묶음(2026-10-20 오늘의 세트):
- 채점 순간 보기 카드 오른쪽에 체크/X 아이콘이 붙으며 보기 표 폭이 줄어 열 위치가 밀리고 텍스트 보기는 줄바꿈이 바뀜(`passql_choice_card.dart:109-124`).
- 결과 표 셀이 고정폭 글꼴(JetBrainsMono)이라 한글 사이 공백이 넓음("알 수 없음", `result_rows_table.dart:70`).
- 실행 결과 카드에 어느 보기를 실행한 결과인지 표시가 없고, 열 이름이 소문자(id)라 스키마 표기(ID)와 다름.
- 인라인 코드 `GROUP BY`가 줄바꿈으로 두 조각 하이라이트로 갈라짐(9번 보기 C).
- 결과 화면 상단 바 제목과 점수 고리 위 캡션이 같은 "오늘의 세트"로 중복.

## 재현 조건
2026-10-20 오늘의 세트 풀이 화면(1번 채점 전후, 9번 인라인 코드, 결과 화면).

## 조사 기록
- 2026-10-20: 이슈 본문 추가 요청 — 디자인 토큰, 공통 컴포넌트에서 고쳐 모든 화면에 함께 반영.

## 근본 원인
공통 위젯 단위의 시각 결함들. 원인은 증상 항목별 위치로만 적혀 있다.
