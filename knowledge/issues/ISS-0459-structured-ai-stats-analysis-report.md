---
type: completion-report
id: ISS-0459
created: 2026-11-07
topics: [ai, progress-stats, billing]
status: resolved
resolves: "[[ISS-0459-structured-ai-stats-analysis]]"
related: ["[[DEC-0259-ai-analysis-server-decides-llm-explains]]"]
source: "_sources/issues/ISS-0459-structured-ai-stats-analysis-report.md"
---

# ISS-0459 완료 리포트: 서버 판정 + AI 한 문장 구조화 분석

GitHub #861 리포트 기준 (2026-11-07). 커밋 a478bc37, bd0e9e67, ec066cb5.

## 해결 방법
- `AiAnalysisPlanner` (순수 규칙): 판정(5문제 미만 판단 이름, 60% 미만 약점, 75% 미만 불안정) > 집중 토픽 2개(1과목 우선 > 약점 > 불안정 > 판단 이른 토픽 1개, 같은 판정은 틀린 수 많은 순) > 강점(10문제·85%) > 한 줄 진단·주간 추세 > 버튼(토픽 5문제 풀기, 최근 오답 최대 5문제).
- 데이터: 최근 90일 토픽 수치(문제별 마지막 시도), 세부 주제 정답률, 최근 오답 8개, 2주 집계, 시험 일정. 1과목은 토픽 코드 `data_modeling`.
- LLM: 운영 DB 프롬프트 `ai_analysis_stats` (변수 `{focusTopics}`·`{subtopicStats}`·`{recentWrongs}`), 출력 해석은 펜스 제거·모르는 토픽 무시·첫 문장·70자·해요체 아니면 버림.
- 응답 `AiCommentResponse.analysis` 추가, 구버전 앱용 `comment` 평문 유지, LLM 실패 결과는 캐시 안 함.
- 앱·웹 AI 분석 카드 재구성 (웹은 오답 노트 화면이 없어 오답 버튼 숨김).

## 검증
- 운영 관리자 프롬프트 테스트 8회 형식·근거 규칙 준수, 서버 판정 테스트 8개·해석 테스트 3개, `flutter test` 107개, 웹 테스트 통과, 카드 라이트·다크 렌더 확인 (예시 데이터).
- 실제 회원 데이터 검증은 배포 후 (GitHub #861 후속 댓글).

## 근본 원인 (확정)
LLM 에 판정까지 맡기고 판정 재료만 준 구조.

## 재발 방지
- 숫자로 정할 수 있는 것은 서버가 정하고, LLM 에는 서술(왜)만 맡긴다 ([[DEC-0259-ai-analysis-server-decides-llm-explains]]).
- 지시문은 운영 DB 새 버전으로만 바꾼다 (레포·이슈에 본문 금지).

## 알고 남긴 것
- 통계 화면 토픽 표(7일)와 AI 분석(90일) 기준 기간 차이 > 표기 GitHub #862.
- 데이터 부족·모두 안정권 화면이 허전함, 과목별 예상 점수·개념 바로 가기·결과 화면 세션 코멘트 개편 > GitHub #862.
- 운영 DB `ai_analysis_stats` v1·v2(실험 버전) 켜짐 상태, 최고 버전 v3 사용.

## 교훈
LLM 출력 품질 문제는 지시문을 다듬기 전에 "무엇을 LLM 이 정하고 있나"부터 본다. 숫자 규칙이 섞여 있으면 서버로 뺀다.
