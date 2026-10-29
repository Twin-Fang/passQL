---
type: issue
id: ISS-0029
created: 2026-04-09
topics: [ai, practice, question-bank]
symptoms: ["선택지 고정", "정답 패턴 암기", question_choice_set, answer_sql, 프리페치, "선택지 세트 생성", "체감 지연"]
root_cause: "선택지가 문제에 고정되어 반복 풀이 시 정답 패턴이 외워지고, 샌드박스 검증 기반 정답 판정·선택지 세트 관리 모델이 없었다"
status: resolved
resolution: null
related: ["[[DEC-0028-realtime-choice-set-with-prefetch]]", "[[DEC-0029-python-ai-server-primary-gemini-fallback]]", "[[DEC-0030-answer-sql-sandbox-ground-truth]]", "[[DEC-0013-single-custom-exception-error-code]]"]
source: "https://github.com/Twin-Fang/passQL/issues/39"
---

# ISS-0029: 실시간 AI 선택지 세트 생성 및 프리페치 아키텍처

GitHub #39 (원본: 이슈 본문과 댓글 2개 — 구현 계획, 관리자 문제 등록 설계).

## 증상
- 선택지가 문제에 고정되어 같은 문제를 여러 번 풀면 정답 패턴이 외워졌다.
- "매번 다른 선택지, 실시간 생성"이라는 차별점을 살리지 못했다.
- `question` 테이블이 `answer_sql` 중심이 아니라 샌드박스 검증 기반 정답 판정이 불가능했다.
- 선택지 세트의 상태·출처·재사용을 관리할 모델이 없어 CURATED/HYBRID/신고 처리로 확장할 경로가 막혀 있었다.
- 문제 진입마다 AI를 호출하면 체감 지연이 큰데 프리페치 전략이 없었다.
설계 문서: `docs/superpowers/specs/2026-04-09-realtime-choice-set-generation-design.md`. 계획: Flyway `V0_0_28`(question 재설계 + `question_choice_set`, `question_choice_set_item`, `quiz_session`, `submission` 확장), 관리자 AI 보조 문제 등록, 선택지 세트 대시보드.

## 재현 조건
같은 문제를 반복해서 풀면 같은 선택지가 나온다 (이슈 본문).

## 조사 기록
- 2026-04-09: 「Admin 문제 등록(AI 생성) + 프롬프트 테스트 Implementation Plan」 댓글 — `AiGatewayClient`(Python AI Server 호출 + Spring `GeminiClient` fallback), `gemini-2.5-flash-lite`, 프롬프트 테스트·버전 활성화 페이지, `V0_0_24__add_generate_prompt_templates.sql`. 미결 사항: EXECUTABLE 정답 판별을 Gemini `is_correct`로 할지 샌드박스 결과로 override할지 관리자가 결정, `sandboxDbName` 채번.
- 2026-04-09: 「Admin 문제 등록 (AI 생성) + 프롬프트 테스트 설계」 댓글(작성일 2026-04-08, GitHub #22 연계로 표기) — 선택지 4개 고정(A~D, 기존 A~E 5개에서 변경), EXECUTABLE은 샌드박스 실행으로 정답 자동 판별(관리자 수정 가능), CONCEPT_ONLY는 Gemini가 정답+rationale. 미결: EXECUTABLE 정답 판별 기준 확정 필요.
- 완료 보고 댓글은 없다.

## 근본 원인
선택지를 문제에 고정한 데이터 모델 (이슈 본문).
