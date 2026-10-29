---
type: decision
id: DEC-0155
created: 2026-10-18
reviewed: null
topics: [ai, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0330-stale-explanation-sheet-empty-result]]", "[[ISS-0330-stale-explanation-sheet-empty-result-report]]", "[[DEC-0146-structured-explanation-once-per-set]]"]
---

# DEC-0155: AI 해설 화면 순서는 판정 → 정답 근거 → 시험 팁 → 핵심 개념 → 헷갈리는 지점 → 보기별 판단

## 문제 정의 (Context)
AI 해설의 "시험 팁"이 본문 끝, 면책 문구 바로 위에 있어 눈에 띄지 않았다. 이슈 본문은 위치를 제안 후 사용자 확인으로 정하기로 했다(정답 설명 바로 아래 vs 맨 위 등) (GitHub #538).

## 결정 (Decision)
시험 팁을 정답 근거 바로 아래에 둔다. 앱과 웹을 같은 순서로 맞추고, 서버 응답 필드 순서는 그대로 두어 화면 표시 순서만 바꾼다.

## 검토한 대안 (Alternatives)
- 판정 배지 위(맨 위): "왜 정답인가 → 시험에서 이렇게 기억" 흐름이 끊겨서 택하지 않았다.
- 원래 위치(맨 아래): 시험 팁은 풀이 직후 가장 먼저 기억할 한 줄인데 보기 4개 분량의 긴 섹션 뒤에 있었다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 앱 `AiExplanationSections`와 웹 `ExplanationContent` 두 곳의 순서를 함께 맞춰야 한다.

## 영향 범위 (Scope)
앱 `AiExplanationSections`, 웹 `ExplanationContent`.

## 출처 (References)
- GitHub #538 이슈 본문, 보고 댓글 "3. 시험 팁 위치" (2026-10-18)
- [[ISS-0330-stale-explanation-sheet-empty-result]]
