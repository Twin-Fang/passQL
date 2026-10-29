---
type: issue
id: ISS-0043
created: 2026-04-10
topics: [practice]
symptoms: ["스키마 텍스트 덤프", "실행 결과 비교 없음", "자유 SQL 실행 없음", AnswerFeedback, "/execute", "questionUuid DB명", sandboxDbName, "diffExplain question_id: 0"]
root_cause: "FE에 스키마·실행 결과 시각화와 결과 비교 UI가 없었고, BE /execute는 questionUuid.toString()을 샌드박스 DB 이름으로 넘겼으며 SubmitResult에 실행 결과가 없었다"
status: resolved
resolution: "[[ISS-0043-question-screen-result-compare-redesign-report]]"
related: ["[[DEC-0041-result-screen-by-execution-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/70"
---

# ISS-0043: 문제 풀이 화면 — 스키마 텍스트 덤프, 결과 비교 부재, 자유 SQL 실행 부재

GitHub #70 (원본: 이슈 본문과 댓글).

## 증상
1. "스키마 보기"가 테이블 구조·DDL·샘플 데이터를 텍스트 덤프로 보여줘 모바일에서 가로 스크롤이 필요하고 읽기 어렵다.
2. 선택지 실행 결과가 카드 안에 작게 갇혀 비교가 어렵다.
3. `AnswerFeedback`에 실행 결과 비교가 없고, CONCEPT_ONLY 문제에서도 정답/오답 SQL이 표시된다.
4. 문제 스키마 위에서 자유롭게 SQL을 실행할 인터페이스가 없다(`POST /api/questions/{uuid}/execute`는 이미 있음).
5. `diffExplain` 호출에 `question_id: 0` 하드코딩.

## 재현 조건
EXECUTABLE 문제 풀이·제출.

## 조사 기록
- 2026-04-10: 백엔드 리포트 — `/execute`가 `sandboxExecutor.execute(questionUuid.toString(), sql)`로 UUID를 DB 이름으로 넘겨, `sandbox_XXXXXXXX`를 기대하는 `SandboxPool`이 DB를 찾지 못했다.
- 2026-04-10: 프론트 작업 댓글.

## 근본 원인
FE 화면 구성 부족, BE `/execute`의 DB 이름 오용, `SubmitResult` 필드 부족.
