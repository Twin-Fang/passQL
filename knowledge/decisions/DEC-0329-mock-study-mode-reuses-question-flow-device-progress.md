---
type: decision
id: DEC-0329
created: 2026-11-16
reviewed: null
topics: [practice, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0536-mock-exam-study-mode-final-round]]", "[[ISS-0536-mock-study-final-study-guide-report]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[DEC-0331-study-guide-four-stages-progress-counts-study]]", "[[ISS-0528-review-bundle-wrong-note-bookmark-hardest-report]]"]
---

# DEC-0329: 모의고사 학습 모드는 응시 기록을 만들지 않고 회차 50문항을 시험 번호 순서로 기존 문제 풀이 흐름(QuestionFlow)에서 풀며, 진도는 기기에 저장하고, PRO 또는 무료 체험 회차·무료 기출 회차만 학습할 수 있다

GitHub #1084 (이슈 본문, 로컬 설계 메모 「결정 요약」, 보고서 댓글).

## 문제 정의 (Context)
모의고사는 시간 제한 실전 모드뿐이라 한 문제씩 정답·해설·실행 결과를 보며 공부할 수 없었다([[ISS-0536-mock-exam-study-mode-final-round]]). 이슈는 "진도 저장"을 요구했다.

## 결정 (Decision)
- **풀이:** 회차 50문항을 시험 번호 순서로 기존 문제 풀이 화면(`QuestionFlow`)에서 푼다. 바로 채점·AI 해설·실행 결과 비교는 풀이 화면 그대로(새 화면 없음). 서버는 회차 문항 uuid 순서만 준다(`GET /api/mock-exams/rounds/{roundUuid}/study-questions`).
- **기록:** 응시 기록을 만들지 않는다 — 점수 추이·예상 합격률·순위에 넣지 않는다(실전 모드만). 풀이는 문제 상세·제출 기존 경로라 크레딧도 기존 규칙.
- **학습 가능(`canStudy`):** PRO, 또는 무료 체험 회차, 또는 무료 기출 회차.
- **진도:** 기기 저장(회차별 정답 여부 목록, `MockExamStudyProgressStore`). 50문항 끝내면 완료 표시, 다음엔 처음부터. 서버 저장은 후속.
- 실전 이어 풀기 중인 회차는 학습 모드 버튼을 숨긴다.

## 검토한 대안 (Alternatives)
- 학습 진도 서버 저장: 설계 메모 「하지 않는 것」에 "기기 저장으로 시작, 필요하면 후속"으로 제외. 그 밖의 비교·이유는 논의 기록 없음.
- 학습 모드 전용 새 풀이 화면: 논의 기록 없음(설계 메모는 "새 화면 없음"만 적음).
- 학습 가능 범위의 다른 안(전체 무료 등): 논의 기록 없음. 참고로 #1079 댓글이 기출 무료 범위 후보로 "학습 모드만 무료"를 올렸으나 채택되지 않았다([[DEC-0328-past-exam-rewrite-operation-rules]]).

## 결과 (Consequences)
**긍정**
- 풀이·채점·해설·실행 비교를 새로 만들지 않고 기존 풀이 흐름을 재사용한다(보고서 「학습 모드」).

**부정**
- 다른 기기나 재설치면 진도가 처음부터 시작한다(보고서 주의 사항).
- 학습 모드 풀이는 점수 추이·예상 합격률·순위에 반영되지 않는다(보고서 주의 사항).

## 영향 범위 (Scope)
서버 모의고사 공개 API(`study-questions`, 회차 목록 `canStudy`), `api-contract/openapi.json`. 앱 `MockExamStudyFlow`, `QuestionFlow.onQuestionAnswered`, `MockExamStudyProgressStore`, 시험 안내 하단 버튼. 학습 가이드 진행 계산([[DEC-0331-study-guide-four-stages-progress-counts-study]])이 기기 학습 완료를 읽는다.

## 출처 (References)
- 이슈 https://github.com/Twin-Fang/passQL/issues/1084
- 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1084#issuecomment-6904383937
- 설계 메모(로컬) `docs/superpowers/specs/2026-11-16-1084-1078-mock-study-final-guide.md`

## W4 검사
- [[DEC-0264-mock-exam-fixed-rounds-server-judged]](무료 1회 체험, 모의고사 답은 응시 기록으로 남기고 하루 무료 한도에서 제외, 문항 해설은 프로): 학습 모드는 응시를 만들지 않는 별도 경로라 실전 응시 규칙(체험 1회·서버 타이머·채점·등급 가림)은 그대로다. 학습 모드 풀이는 일반 문제 풀이 규칙(크레딧·해설 공개 범위)을 따른다. 대체하지 않고 **조건부 공존**(실전 = DEC-0264, 학습 = DEC-0329)으로 기록. 무료 체험 회차를 학습 모드로 반복 풀 수 있게 한 점이 사용자 확인을 거쳤는지는 원본에 명시가 없다(설계 메모 결정 요약에 포함, 구현·배포됨).
- [[DEC-0328-past-exam-rewrite-operation-rules]](가장 최근 기출 1회차 무료): `canStudy`가 무료 기출 회차를 포함 — 같은 방향, 충돌 없음.
- [[DEC-0301-mock-exam-ranking-first-attempt-top-percent]](순위 = 회원별 첫 응시): 학습 모드는 응시가 아니라 순위에 들어가지 않음 — 충돌 없음.
