---
type: completion-report
id: ISS-0547
created: 2026-11-23
topics: [question-bank, practice]
status: resolved
resolves: "[[ISS-0547-past-exam-real-exam-level-rewrite]]"
related: ["[[DEC-0350-past-exam-real-exam-level-standard]]", "[[DEC-0351-choice-order-fixed-and-round-choice-set-repoint]]", "[[LSN-0008-import-update-breaks-round-choice-set]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1155"
capture_mode: "issue-end"
captured_at: "2026-11-23T21:49:53+09:00"
captured_by: "pro-brain"
project: "passql"
stacks: ["spring"]
app_version: "1.143.5"
build_number: 613
issue: 1155
issue_url: "https://github.com/Twin-Fang/passQL/issues/1155"
pr: 1173
pr_url: "https://github.com/Twin-Fang/passQL/pull/1173"
commit_base: "da0e47c33fa883eccb816a00fec19f891d7c4ee3"
commit_head: "f42961da69c37a049bafa27a4e5a1a4d1db27837"
commit_count: 4
merge_commit: "f9b0a37b24318b4275049cc5488951ded7166046"
changed_modules: ["docs", "tools", "server/PQL-Domain-Question", "server/PQL-Domain-Submission"]
lines_added: 1340
lines_deleted: 144
deployed: true
deploy_targets: ["server", "ai", "web", "play", "testflight"]
deploy_version: "1.144.0"
---

# ISS-0547 완료 리포트: 45~63회 950문항 실제 시험 수준 반영, 63회 신규, 회차 보기 세트 자동 재연결 (#1155)

보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1155#issuecomment-7101682085 · PR #1173 > 배포 PR #1174 (v1.144.0)

## 해결 방법
- 문항: 45~63회 950문항을 보정판(v4)으로 운영 갱신(기존 uuid 유지). 기준은 [[DEC-0350-past-exam-real-exam-level-standard]]. 원본은 `docs/sqld-research/past-exams-v4/`(암호화본만 커밋), 반영 도구 `docs/sqld-research/past-exams-tools/register_rounds.py`.
- 서버: `CuratedChoiceSetWriter > replaceCuratedSet()` 이 `CuratedChoiceSetReplacedEvent` 발행 > `MockExamRoundItemChoiceSetRepointListener` 가 같은 트랜잭션에서 회차 문항을 새 세트로 재연결. `ChoiceOrderShuffler` 는 보기 글이 ①~④·(가)·ㄱ 으로 시작하면 섞지 않음 — [[DEC-0351-choice-order-fixed-and-round-choice-set-repoint]].
- 도구: `tools/question-figure` 에 보기 그림 격자, 결과 표 보기, 큰 ERD·속성 라벨, 키 정의 표, 피터 첸, 상호배타 호 추가(기존 그림 50개 출력 동일).

## 검증
- 회차마다 lint 0, Oracle 21c 50/50, 5-gram 0.35 이하, 서버 가져오기 검증·공개 검사 통과. 조합형·차례 실행은 진술마다 Oracle 직접 실행.
- 서버 테스트 241개 통과. 배포 후 재반영에서 회차 재연결 0건 = 서버 자동 재연결 동작 확인.
- 앱 실측(시뮬레이터, 운영, 실제 계정): 그림 보기 격자·ERD 보기·표 + SQL 표시, 보기 ①~④ 순서 고정.

## 남은 것
- 50·51회는 13~20줄 SQL이 기준보다 1개 적음(길이를 꾸미지 않음). 실제 시험 수준 기준은 추정이라 새 응시 후기가 나오면 다시 맞춘다.
