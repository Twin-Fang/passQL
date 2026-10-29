---
type: completion-report
id: ISS-0350
created: 2026-10-21
topics: [question-bank]
status: resolved
resolves: "[[ISS-0350-public-question-full-audit]]"
related: ["[[DEC-0165-numeric-choices-ascending]]"]
source: "https://github.com/Twin-Fang/passQL/issues/565"
---

# ISS-0350 완료 리포트: 운영 데이터 수정 불필요, 숫자 보기는 오름차순 고정

GitHub #565 리포트 댓글(`## 개요`, 2026-10-21) 기준.

## 해결 방법
- `ChoiceOrderShuffler.java`: 보기가 모두 숫자면 섞지 않고 오름차순(정수·소수), 그 외는 기존처럼 무작위 섞기.
- `QuestionService.java`: 섞기 호출 2곳에 보기 본문 전달.
- `ChoiceOrderShufflerTest.java`: 숫자 보기 20회 반복 오름차순 고정 테스트.
- 운영 데이터 수정은 필요 없었다.

## 근본 원인 (확정)
숫자 보기 순서는 서버의 고정 보기 표시 순서 무작위 섞기 때문.

## 재발 방지
- 검증: 서버 단위 테스트 통과, 운영 `passql-back-green` `sha-08554b7` healthy, 기동 후 ERROR 0. 앞으로 들어오는 문제는 GitHub #555의 가져오기 검증·RESULT_MATCH 재생성·하네스 린터로 차단.
- 주의: 숫자 판별은 본문 전체가 숫자일 때만("3행", "1,000"처럼 글자 섞인 보기는 섞인다). 비활성 문제의 옛 AI 세트는 남아 있어 문제를 다시 활성화할 때는 세트를 재생성한다.

## 교훈
(원본에 없음, 볼트 정리) 보기 순서 이상은 데이터보다 표시 단계(섞기) 코드부터 확인한다.
