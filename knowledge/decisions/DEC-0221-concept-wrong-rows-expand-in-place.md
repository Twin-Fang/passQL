---
type: decision
id: DEC-0221
created: 2026-10-30
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0432-app-concept-tab-redesign]]", "[[ISS-0432-app-concept-tab-redesign-report]]", "[[DEC-0218-concept-result-ring-climax]]", "[[DEC-0219-keep-one-line-headlines-visualize-instructions]]"]
---

# DEC-0221: 틀린 문제는 풀이 시트 대신 목록 줄을 눌러 그 자리에서 펼친다

## 문제 정의 (Context)
결과 화면의 문제 칩을 누르면 풀이 시트가 떴다 (GitHub #764 첫 시안). 4문제를 연달아 보려면 시트가 뜨고 닫히는 왕복이 생기고, 칩 「× 2 ›」는 눌러서 무엇이 나올지 알 수 없었다. 토스 원칙(예측 가능한 힌트, 핵심 메시지 집중)과 맞지 않았다.

## 결정 (Decision)
- 결과 화면에 「다시 볼 문제 N」 목록을 두고 틀린 문제만 한 줄씩(번호 배지 + 지문 한 줄) 보여 준다. 쉐브론이 아래를 향해 펼쳐짐을 예고한다.
- 줄을 누르면 그 자리에서 아래로 열려 내 답(빨강 ×) · 정답(초록 ✓) · 풀이 · 「N. 문단 제목 다시 읽기」가 보인다. 한 번에 하나만 열린다. 풀이 시트(`concept_answer_review_sheet.dart`)는 삭제했다.
- 다시 읽고 돌아오면 그 줄의 배지가 강조색 체크로, 줄 아래에 「N. 제목 읽음」이 붙는다 (결과 화면이 사라지기 전까지, 서버 저장 없음).
- 하단 왼쪽 버튼은 「틀린 문제 풀기」(틀린 수는 제목·목록에 이미 있어 뺌), 다 맞히면 「다시 풀기」.

## 검토한 대안 (Alternatives)
- 풀이 시트 유지(칩 탭): 시트 왕복과 불명확한 칩 때문에 사용자가 "시트 없음" 방식을 골랐다.
- 줄을 밀어 그 문제만 바로 풀기: 사용자가 "밀기 같은 숨은 제스처 말고 토스스타일로"라 해 채택하지 않았다.

## 결과 (Consequences)
**긍정**
- 틀린 문제를 연달아 훑기 쉽고, 다음 행동이 줄 안에서 이어진다.

**부정**
- 지문이 긴 문제는 한 줄에서 잘려 보인다(펼치면 전체).

## 영향 범위 (Scope)
`app/lib/presentation/widgets/concept/concept_result_view.dart`(`_WrongQuestionRow`), `providers/concept_providers.dart`(`rereadAnchors`).

## 출처 (References)
- GitHub #764 시안 검토와 리포트 댓글
- [[ISS-0432-app-concept-tab-redesign]]
