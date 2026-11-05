---
type: decision
id: DEC-0257
created: 2026-11-05
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0457-concept-animated-diagrams]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]"]
---

# DEC-0257: 결과가 만들어지는 과정은 움직이는 그림 블록으로 보여 주고, 그림도 표 머리글로 구분한다

## 문제 정의 (Context)
레슨 블록([[DEC-0256-concept-lesson-blocks-by-table-header]]) 뒤에도 화면이 전자책 같다는 피드백 (GitHub #853). 조인·조건·집합 연산은 결과 행이 만들어지는 과정이 핵심인데 정지 표로만 보였다.

## 결정 (Decision)
- 그림 블록 3종: 조인 연결(`왼쪽 행 | 오른쪽 행`), 행 거르기(`행 | 처리`, 남음/빠짐/묶음 이름), 집합(`집합 | 값`, 앞 두 줄이 집합, 그 뒤 연산별 결과).
- 그림은 스크롤로 들어올 때 한 번 진행하고(`PassqlScrollProgress`), 집합만 연산 세그먼트로 직접 바꿔 본다.
- 동작 줄이기면 처음부터 최종 모습.
- 외우는 법은 글자 타일을 누르면 뒤집혀 뜻이 보인다.
- 그림 내용은 같은 문단 SQL 의 실제 실행 결과와 같아야 한다 (Oracle 검증 항목).

## 검토한 대안 (Alternatives)
- Lottie·Rive 애니메이션 파일: 개념마다 디자인 작업이 필요하고 내용과 따로 놀아서 버렸다. 논의 기록 없음(에이전트 판단).
- 서버 블록 타입 필드: DEC-0256 과 같은 이유(옛 앱 호환·API 변경)로 버렸다.

## 결과 (Consequences)
**긍정**
- 결과가 왜 그렇게 나오는지 읽지 않고 볼 수 있다. 옛 앱은 일반 표로 보인다.

**부정**
- 머리글 문자열이 계약에 더해진다. 조인 행 칸 높이 고정이라 긴 행 글은 말줄임.

## 영향 범위 (Scope)
`ConceptLessonBlockParser`, `ConceptJoinDiagram`, `ConceptRowFilterDiagram`, `ConceptSetDiagram`, `ConceptStepTimeline`, `ConceptMnemonicCard`, `PassqlScrollProgress`, content/concepts 17개, README 「그림 블록」.

## 출처 (References)
- GitHub #853 PR #856 (2026-11-05)
- 이슈: [[ISS-0457-concept-animated-diagrams]]
