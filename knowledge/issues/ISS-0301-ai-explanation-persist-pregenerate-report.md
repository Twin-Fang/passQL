---
type: completion-report
id: ISS-0301
created: 2026-10-16
topics: [ai, practice]
status: resolved
resolves: "[[ISS-0301-ai-explanation-persist-pregenerate]]"
related: ["[[DEC-0137-pregenerate-choice-explanations-db]]", "[[ISS-0302-app-server-web-performance]]"]
source: "https://github.com/Twin-Fang/passQL/issues/496"
---

# ISS-0301 완료 리포트: 선택지 해설 미리 생성·DB 영구 저장, 제출 응답에 해설 포함

GitHub #496 구현 보고서 댓글 기준 (Spring run `38891584121`, 1.6.0).

## 해결 방법
- 마이그레이션 `V0_10_50`: 선택지 `explanation`, `explanation_prompt_version` 칼럼, `ai_error_explanation` 테이블(문제, SQL 해시, 오류 해시 유니크), 세트 조회 인덱스 `(question_uuid, status, created_at DESC)`.
- `AiExplanationGenerator`(프롬프트 조립·Gemini 호출만), `ChoiceExplanationService`(활성 프롬프트 버전 저장본 재사용, 없거나 낡으면 생성·저장, 세트 단위 미리 생성과 백필).
- `ChoiceSetReadyEvent` + 리스너: 검증을 통과한 세트 저장 시 발행, 커밋 뒤 `aiTaskExecutor`에서 미리 생성.
- `ChoiceExplanationBackfillScheduler`: 기동 5분 뒤부터 10분마다 해설 없는 세트 3개씩(Gemini 최대 12회).
- `AiExplainService`: 클래스 단위 트랜잭션과 Redis 캐시 제거. SQL 오류 해설은 정규화(공백, 끝 세미콜론) 후 SHA-256 키로 DB 저장. 입력 길이 상한(SQL 4000자, 오류 1000자), 세트에 없는 선택지 키 거절.
- `SubmitResult.explanation`: 고른 선택지의 저장된 해설(계약·웹 생성 타입 갱신).
- 앱: `AiExplainSheet.show(initialExplanation)` 저장본이 있으면 요청 없이 표시. 단건 결과 화면이 정답 키를 보내던 오류는 키를 빼서 서버가 마지막 제출로 찾게 수정.
- 웹: 해설 카드·연습 피드백 바가 저장된 해설을 rationale보다 먼저 보여 주고 머리 문구 "AI 해설".
- 검증: `AiExplainServiceTest` 9개, 서버 전체(기존 dev DB 외래키 테스트 1개 제외) 통과, 앱 전체·웹 vitest 47개 통과. 운영 flyway `0.10.50` 적용, 기동 5분 뒤 백필이 첫 세트 A·B 해설 저장 확인. 선택지 항목 420개라 전부 채우는 데 몇 시간.

## 근본 원인 (확정)
이슈 본문과 같음. 함께 고친 버그: 단건 결과 화면이 고른 키 대신 정답 키를 보내 오답 해설이 정답끼리 비교한 내용이 됨.

## 재발 방지
주의(원본):
- 아직 미리 생성되지 않은 세트를 풀면 첫 해설 요청 때 만들어 저장한다(그 사람만 기다림).
- REAL 모드는 문제를 열 때마다 새 세트를 만들어 세트마다 해설 4건을 만든다. 비용이 문제가 되면 REAL 모드는 요청 시 생성만 하도록 바꾸면 된다.
- 백필 속도·양은 `ChoiceExplanationBackfillScheduler.SETS_PER_RUN`과 주기로 조정.
- 해설 길이가 프롬프트 규칙(600자)보다 길게 나오는 경우가 있다. 프롬프트는 관리자 화면에서 조정.

## 교훈
(원본에 없음, 볼트 정리) 회원과 무관한 입력으로 만드는 LLM 결과는 캐시보다 생성 시점 저장이 비용·일관성 모두 낫다. 해설이 이상하면 `explanation_prompt_version`이 활성 프롬프트 버전과 같은지 본다.
