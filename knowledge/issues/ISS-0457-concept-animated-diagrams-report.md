---
type: completion-report
id: ISS-0457
created: 2026-11-05
topics: [concept-learning, design-system]
status: resolved
resolves: "[[ISS-0457-concept-animated-diagrams]]"
related: ["[[DEC-0257-concept-animated-diagram-blocks]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]"]
source: "_sources/issues/ISS-0457-concept-animated-diagrams-report.md"
---

# ISS-0457 완료 리포트: 조인 연결·행 거르기·집합 그림과 뒤집는 암기 타일

GitHub #853 리포트 기준 (2026-11-05). PR #856.

## 해결 방법
- 그림 블록 3종, 표 머리글로 구분 ([[DEC-0257-concept-animated-diagram-blocks]]):
  - 조인 연결 `왼쪽 행 | 오른쪽 행`: 짝마다 곡선을 차례로 긋고, 짝 없는 행은 NULL 칸과 주황 선.
  - 행 거르기 `행 | 처리`: 빠지는 행 흐림·줄긋기·빼기 표시, 남는 행 체크, 묶음 색 띠·이름표, 끝에 남은 행 수.
  - 집합 `집합 | 값`: 겹친 두 원, 연산 세그먼트로 칠하는 영역·결과 전환.
- 단계 연결선이 차오름, 외우는 법 글자 타일 뒤집기(한 줄 맞춤).
- `PassqlScrollProgress`: 스크롤로 들어오면 0 > 1 한 번 진행, 동작 줄이기면 최종 모습.
- 개념 17개에 그림 29개 (조인 9, 행 거르기 18, 집합 2).

## 검증
- `flutter analyze` 0건, `flutter test` 107개 통과, 개념 구조 검증 63개 경고 0.
- Oracle 검증: 그림을 넣은 단원은 작업 직후 통과. 이후 디스크 가득 참으로 Docker 가 멈춰 전체 재실행은 못 함 (개념 글 변경 없음).
- iOS 18.3 시뮬레이터 실측 캡처 5장 (#853 댓글).

## 근본 원인 (확정)
정지 블록뿐인 화면.

## 재발 방지
- content/concepts/README.md 「그림 블록」 작성 규칙.

## 알고 남긴 것
- 조인 연결 행 칸 높이 고정 — 행 글은 짧게.
- 집합 칠하기는 연산 이름으로 판정 (UNION 전체, INTERSECT 겹침, MINUS·EXCEPT 왼쪽만).
- 집합 연산자 개념은 그림 아래 같은 내용 표가 남아 있음 (정리 여부 미정).
