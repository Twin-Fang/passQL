---
type: issue
id: ISS-0459
created: 2026-11-07
topics: [ai, progress-stats, billing]
symptoms: ["AI 코멘트 식상", "AI 분석 빈말", ai_comment_stats, "정답률 반복", "시험 일정 모름", "1과목 과락", "AI 판정 규칙 위반", AiCommentResponse, analysis]
root_cause: "AI 에 토픽 정답률만 주고 판정까지 맡겨, 화면 숫자 반복·빈말·규칙 위반(1과목 무시, 표본 적은 토픽 약점 판정)이 나옴"
status: resolved
resolution: "[[ISS-0459-structured-ai-stats-analysis-report]]"
related: ["[[DEC-0259-ai-analysis-server-decides-llm-explains]]", "[[DEC-0258-ai-comment-pro-only-all-forms]]", "[[ISS-0458-server-side-free-limit-pro-gating]]"]
source: "_sources/issues/ISS-0459-structured-ai-stats-analysis.md"
---

# ISS-0459: 통계 AI 분석을 프로 요금제답게 (오답 패턴 진단과 바로 풀기 버튼)

GitHub #861 (원본: 이슈 본문). 지시문 본문은 운영 DB 에만 있고 원본·노트에 없다.

## 증상
- 통계 화면 AI 코멘트가 토픽별 정답률만 받아 2~3문장으로 다시 읽어 줌. 사용자: "AI코멘트 지금 굉장히 식상하거든", "지금솔직히 퀄리티가 안좋아서".
- 시험 일정·시험 구조(1과목 과락)를 몰라 우선순위가 시험 기준이 아님, "개념 정리"·"꾸준히" 같은 빈말과 입력에 없는 사실("실무 활용도")이 섞임.
- 글만 있고 바로 할 행동으로 이어지지 않음.

## 재현 조건
프로(결제 꺼짐이면 전원) 회원이 통계 화면을 열 때.

## 조사 기록
- 2026-11-07: 현재 지시문을 가상 사용자 4유형으로 `claude -p` (haiku) 2회씩 실행 > 위 증상 확인.
- 2026-11-07: 입력 보강(세부 주제 정답률, 최근 오답 제목, 주간 추세, 준비도, 시험 일정) + 구조화 출력 지시문 > 품질 향상, 그러나 운영 AI(관리자 프롬프트 테스트)에서 판정 규칙 위반 다수 (1과목 50% 누락, 3문제 토픽 약점, 1문제 토픽 강점, 오답 3개인데 8문제 버튼).
- 2026-11-07: 판정을 서버로 옮기고 AI 는 토픽별 한 문장만 > 운영 AI 8회 위반 0 (권유 문장 1회는 첫 문장만 쓰기로 걸러짐) > [[DEC-0259-ai-analysis-server-decides-llm-explains]].

## 근본 원인
AI 에 판정 재료(토픽 정답률)만 주고 판정·우선순위·문구까지 맡겼다. 왜 틀리는지 말할 재료가 없고, 숫자 규칙은 LLM 이 안정적으로 지키지 못했다.
