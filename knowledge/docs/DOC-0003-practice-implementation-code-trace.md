---
type: doc
id: DOC-0003
doc_type: design
authority: internal
created: 2026-11-13
reviewed: null
source: "https://github.com/Twin-Fang/passQL/tree/118159a8"
topics: [practice]
topics_ref: [billing, ai, ads]
decisions: []
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0040-choice-response-hides-answer]]", "[[DEC-0251-practice-reuse-random-validated-sets]]", "[[DEC-0271-daily-limit-judged-in-submit-record-tx]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]", "[[DEC-0287-credit-term-top-bar-balance]]", "[[DEC-0306-credit-history-computed-from-limit-records]]", "[[DOC-0001-billing-implementation-code-trace]]", "[[DOC-0004-ai-implementation-code-trace]]"]
---

# DOC-0003: 문제 풀이·제출·실행·하루 한도·크레딧 구현 코드 추적 — 서버·앱

## 요약
2026-11-13 main(`118159a8`, v1.120.0) 코드를 직접 따라가 정리한 문제 풀이 구현 지도다. 앱은 문제 상세를 받고, 선택지는 SSE로 받으며(정답 없이), 고른 보기를 제출하면 서버가 선택지 세트로 채점·기록한다. 무료 하루 한도(크레딧)는 별도 잔액을 저장하지 않고 "오늘 제출한 서로 다른 문제 수 <-> 10 + 보너스"로 매번 계산하며, 열기와 제출 두 시점에서 같은 판정을 한다. 제출 판정은 기록 트랜잭션 안 회원 행 잠금 뒤에 해 동시 제출이 한도를 넘지 못한다. 코드가 바뀌면 이 문서는 낡으므로, 인용 전에 파일이 아직 있는지 확인한다.

## 핵심 내용 · 논점

### 스택별 역할
| 스택 | 역할 | 주요 위치 |
|---|---|---|
| 서버 | 문제 조회, 선택지 공급, 채점·기록, SQL 실행, 하루 한도, 오늘의 세트, 크레딧 내역 | `PQL-Web/.../QuestionController`·`DailySetController`·`MemberController`, `PQL-Domain-Submission/.../SubmissionService`, `PQL-Application/.../entitlement/`(`FeatureAccessPolicy`, `DailyQuestionSubmitAdmission`, `DailyQuestionCounter`, `DailyFreeBonusReader`, `DailyFreeBonusRule`, `CreditHistoryService`), `.../service/`(`QuestionExecutionService`, `DailySetService`, `ChoiceGenerationStreamService`) |
| 앱 | 상세·선택지 준비, 선택·실행, 제출, 결과·사용량 갱신 | `app/lib/presentation/providers/question_providers.dart`(`QuestionInteractionNotifier`), `data/sources/question_api.dart`·`sse_question_client.dart`·`daily_set_api.dart`·`member_api.dart`, `presentation/pages/questions/`, `pages/daily_set/` |

### 문제 열기
1. `GET /api/questions/{uuid}` > `FeatureAccessPolicy.assertCanOpenQuestion`(하루 한도 판정, 아래) > `QuestionFeatureAccessPolicy.isDailySetFreeTrial`(오늘의 세트 무료 체험 표시) > `QuestionDetailService.getQuestionForSolving`.
2. 문제 목록 진입점: `GET /api/questions`(필터 목록), `GET /api/questions/random`(`RandomPracticeService`), `POST /api/questions/recommendations`(`RecommendationService`), `GET /api/questions/lockscreen`(잠금화면 1문제).

### 선택지 받기 (SSE)
- `POST /api/questions/{uuid}/generate-choices`(text/event-stream): SSE 시작 전에 같은 한도 판정(거부는 일반 JSON 오류) > `ChoiceGenerationStreamService.streamChoiceGeneration`이 별도 스레드에서 진행.
- 이벤트 순서 `status(generating)` > `status(validating)` > `complete` 또는 `error`. 세트 확보는 `ChoiceSetResolver.resolveForUser`(모드 조회, 무료는 실전 > 연습 보정): 고정 보기(`CURATED_ONLY`)면 관리자 세트 그대로, 연습 모드는 본인 프리페치 > 검증 통과 세트 > 없으면 생성, 실전 모드는 생성. 생성 상세는 [[DOC-0004-ai-implementation-code-trace]].
- 앱 `QuestionInteractionNotifier.initializeChoices`: 상세에 OK 세트가 있고 새 보기 모드가 아니면 재사용, 아니면 `startSseGeneration`.

### SQL 실행 (보기 ▶)
- `POST /api/questions/{uuid}/execute` {`sql`} > `QuestionFeatureAccessPolicy.requireFeature(SQL_EXECUTION, 문제)`(프로 또는 오늘의 세트 체험 문제만) > `QuestionExecutionService.executeChoice`(문제의 `sandboxDbName` 기준 실행).
- 앱 `runChoice`: 무료(결제 켜짐)면 실행 없이 잠금 표시(체험 문제 제외), 아니면 앱 캐시 우선 > 서버 실행(서버도 결과 캐시).

### 제출·채점
1. `POST /api/questions/{uuid}/submit` {`choiceSetId`, `selectedChoiceKey`, `sessionUuid`} > `SubmissionService.submit`.
2. 짧은 트랜잭션(`TransactionTemplate`): `DailyQuestionSubmitAdmission.forQuestion`이 만든 확인을 첫 단계로 실행(회원 행 잠금 > `assertCanSubmitQuestion`) > `gradeAndRecord`.
3. `gradeAndRecord`: 세트 조회 > 세트 문제 <-> URL 문제 대조(다르면 400 `QUIZ_SESSION_CHOICE_SET_MISMATCH`) > 내린 세트·비활성 문제 거부 > 고른 보기·정답 보기 조회 > 정오 판정 > 첫 제출이면 세트 `consumedAt` 기록 > `Submission` 저장.
4. 트랜잭션 밖: 실행형(`EXECUTABLE`) 문제이고 `shouldRunSandbox`(실행 결과를 볼 수 있는 회원)면 고른 SQL과 정답 SQL을 `CachedSandboxExecutor.executeAll`로 실행. 결과 표 보기 정답은 문제의 정답 SQL을 쓴다.
5. 세트 저장본 구조화 해설이 있으면 고른 보기 기준으로 붙인다(`ChoiceExplanationComposer`).
6. 응답은 `ProResponseRedactor.redactSubmitResult`가 무료 회원 몫 밖 묶음을 뺀다.
7. 앱 `submit` 성공 > 무료(결제 UI 대상)면 등급을 다시 받아 남은 크레딧 표시를 갱신(기다리지 않음).

### 하루 한도 판정 (`FeatureAccessPolicy.assertWithinDailyQuestionLimit`, 열기·제출 공통)
1. 회원 기준 결제 꺼짐 > 통과.
2. 오늘의 문제(`daily_challenge`) 배정 문제 > 통과.
3. 예전에 제출한 적 있는 문제(모의고사 제출 제외) > 통과.
4. 오늘(KST) 제출한 서로 다른 문제 수(`DailyQuestionCounter.countTodayRandomSolved`, 오늘의 문제 배정분 제외)가 `DAILY_FAIR_USE_LIMIT` 200 이상 > 429 `FAIR_USE_DAILY_LIMIT_REACHED`(무료·프로 공통).
5. 프로 > 통과. 무료는 `DAILY_FREE_LIMIT` 10 + 오늘 보너스 합 이상이면 403 `FREE_DAILY_LIMIT_REACHED`.
- 열기는 자리를 맡지 않는다. 여러 문제를 열어 두고 몰아 제출해도 제출 시점 수로 다시 막힌다.

### 보너스와 크레딧 내역
- 보너스 규칙 `DailyFreeBonusRule`: 세트 완료 +5, 세트 정답률 80% 이상 +5, 광고 시청 1회당 +5(횟수 제한 없음). 재료는 `DailyFreeBonusReader`가 날짜별로 모은다(세트 완료 기록, 그날 배정 문제, 배정 문제 그날 제출, 광고 보너스 횟수).
- 광고 보너스 기록 경로는 [[DOC-0005-ads-implementation-code-trace]].
- `GET /api/members/me/credit-history?days=N`(기본 14, 1~30) > `CreditHistoryService`: 전용 테이블 없이 `countRandomSolvedByDate`·`readByDate`로 날짜별 받은 수·쓴 수·남은 수 계산, 결제 켜진 무료 회원에게만.

### 오늘의 세트
- `GET /api/daily-set/today`(`HomeService.getToday`), `POST /api/daily-set/complete`(`DailySetService.complete`), `GET /api/daily-set/leaderboard`.
- 완료 점수는 클라이언트 값을 믿지 않고, 오늘 세트 문제별 오늘 첫 제출(세션 무관)로 서버가 계산한다. 같은 날 두 번 완료는 `DAILY_SET_ALREADY_COMPLETED`(서버 사전 검사 + DB 유니크).

## 추출된 결정
없음. 이미 구현된 내용을 지도로 옮긴 문서라 새 결정은 만들지 않았다. 관련 결정은 `related`에 연결했다.

W4 대조(구현 vs 활성 결정): DEC-0040(선택지 응답에 정답 없음, 채점은 서버), DEC-0251(연습 모드 검증 세트 재사용), DEC-0271(한도 판정은 제출 기록 트랜잭션 안), DEC-0282(광고 보너스 횟수 제한 없음, 공정 사용 200), DEC-0306(크레딧 내역 계산)과 코드가 일치했다. 충돌 없음. 결정 본문은 읽지 않고 클러스터 한 줄 요약과 대조했다.

## 열린 질문
- **열기 판정과 제출 판정의 간격**: 문제를 열 때 통과해도 제출 시점에 한도에 걸릴 수 있다. 앱이 이 거절을 어떤 화면으로 보여 주는지는 이번에 따라가지 않았다.
- **잠금화면 문제**: `GET /api/questions/lockscreen` 경로의 한도 처리([[DEC-0290-lock-screen-question-policy]])는 따라가지 않았다.
- **실행 캐시**: `CachedSandboxExecutor`의 캐시 키·보관 기간은 확인하지 않았다.

## 원본 참조
- 코드 기준: main `118159a8` (2026-11-13, v1.120.0). 원문은 코드 자체이며 별도 텍스트 원본은 없다.
