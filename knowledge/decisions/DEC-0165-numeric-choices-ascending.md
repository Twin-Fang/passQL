---
type: decision
id: DEC-0165
created: 2026-10-21
reviewed: null
topics: [practice, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0350-public-question-full-audit]]", "[[ISS-0350-public-question-full-audit-report]]"]
---

# DEC-0165: 보기가 모두 숫자면 섞지 않고 오름차순으로 보여 준다

## 문제 정의 (Context)
오늘의 세트 8번 숫자 보기가 1, 3, 4, 2로 섞여 보였다. 원인은 서버가 고정 보기 표시 순서를 무작위로 섞는 것(GitHub #512)이었다 (GitHub #555 제안 "숫자 보기는 오름차순 정렬", GitHub #565 구현).

## 결정 (Decision)
`ChoiceOrderShuffler`에서 보기 본문 전체가 숫자(정수·소수)면 섞지 않고 오름차순으로 둔다. 그 외 보기는 기존처럼 무작위로 섞는다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 숫자 보기 순서 섞임이 사라진다.

**부정**
- "3행", "1,000"처럼 글자가 섞인 숫자 보기는 여전히 섞인다.

## 영향 범위 (Scope)
`ChoiceOrderShuffler.java`, `QuestionService.java` 섞기 호출 2곳. 하네스 `balance.numeric-order` 점검(GitHub #555)과 함께 쓰인다.

## 출처 (References)
- GitHub #565 리포트 댓글(2026-10-21), GitHub #555 이슈 본문
- [[ISS-0350-public-question-full-audit]]
