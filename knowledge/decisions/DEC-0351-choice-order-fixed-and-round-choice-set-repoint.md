---
type: decision
id: DEC-0351
created: 2026-11-23
reviewed: null
topics: [question-bank, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0547-past-exam-real-exam-level-rewrite]]", "[[LSN-0008-import-update-breaks-round-choice-set]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
---

# DEC-0351: 번호·조합으로 시작하는 보기는 섞지 않고, 보기 세트가 교체되면 회차 문항을 같은 트랜잭션에서 새 세트로 재연결한다

GitHub #1155.

## 문제 정의 (Context)
- 학습·일반 풀이는 보기 순서를 섞는다(`ChoiceOrderShuffler`). 그림·결과 표 보기(그림 속 ①~④)나 조합형((가), (다))은 섞이면 화면 보기 자리와 그림 번호가 어긋난다.
- 회차 문항은 보기 세트를 고정 참조해, 가져오기로 보기 세트가 교체되면 옛 세트를 가리켜 "새 지문 + 옛 보기"가 나갈 수 있었다.

## 결정 (Decision)
- 보기 글이 ①~④, (가)~(하), ㄱ~ㅎ 로 시작하면 저장 순서 유지. 그래서 그림·표 보기 글은 반드시 번호로 시작하게 쓴다("① 관계선 그림").
- `CuratedChoiceSetWriter > replaceCuratedSet()` 이 `CuratedChoiceSetReplacedEvent` 를 발행하고 Submission 의 `MockExamRoundItemChoiceSetRepointListener` 가 같은 트랜잭션에서 그 문제의 회차 문항을 새 세트로 재연결(초안·공개·보관 무관). 재연결이 실패하면 세트 교체도 롤백. Question 도메인은 Submission 을 모른다(이벤트로 분리).
- 응시 기록은 건드리지 않음(점수는 저장값 유지, 진행 중 응시는 새 세트 정답으로 채점).

## 검토한 대안 (Alternatives)
- 그림 번호를 보기 글 뒤에 두는 형식: 순서 고정 규칙에 걸리지 않아 실측에서 섞임 확인 > 버림.
- 운영 DB 수동 재연결만 유지: 갱신마다 잊으면 공개 회차가 깨져 서버 수정으로 대체.

## 결과 (Consequences)
배포 후 문항 재반영에서 회차 재연결이 0건 = 서버가 자동 처리. 보기 순서 판단이 보기 글 첫 글자에 의존한다.

## 영향 범위 (Scope)
`server/PQL-Domain-Question` > `ChoiceOrderShuffler`, `CuratedChoiceSetWriter`, `server/PQL-Domain-Submission` > `MockExamRoundItemChoiceSetRepointListener`, 문항 작성 규칙(그림·표·조합 보기 글).

## W4 검사
- [[DEC-0264-mock-exam-fixed-rounds-server-judged]](모의고사 회차 고정 구성): 회차 문항 구성은 그대로, 세트만 최신으로 — 충돌 없음.
