---
type: decision
id: DEC-0017
created: 2026-04-07
reviewed: null
topics: [practice, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0011-screen-spec-api-mapping]]", "[[ISS-0012-design-system-screen-ui]]"]
---

# DEC-0017: 제출 결과 화면은 풀스크린 1종으로 통일 (bottom sheet 변형 미채택)

## 문제 정의 (Context)
디자인 시안에 결과 화면이 3가지 스타일로 있었다 (GitHub #8).

## 결정 (Decision)
bottom sheet 변형은 채택하지 않고 풀스크린 결과 화면 1종으로 통일한다. 오답 케이스는 "내가 선택한 답" vs "정답" 카드와 학습 포인트, 정답 케이스는 해설 카드, 하단 sticky [다음 문제 풀기].

## 검토한 대안 (Alternatives)
- Bottom sheet 결과 변형: 컷오프 표 사유는 "풀스크린으로 통일". 그 밖의 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
결과 화면 라우트(`/questions/:id/result`). GitHub #9에서 `AnswerFeedback`을 AppLayout 밖 독립 라우트로 두어 풀스크린으로 구현.

## 출처 (References)
- GitHub #8 이슈 본문 「핵심 원칙」·「컷오프 종합」
