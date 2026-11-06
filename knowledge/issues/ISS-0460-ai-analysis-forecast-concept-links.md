---
type: issue
id: ISS-0460
created: 2026-11-07
topics: [progress-stats, ai]
symptoms: ["AI 분석 카드 비어 보임", "데이터 부족 한 줄", "모두 안정권 다음 할 일 없음", "합격선 모름", "예상 점수 없음", "개념 바로 가기 없음", "90일 7일 기준 차이", "세션 코멘트 일반적", ai_comment, SessionCommentService]
root_cause: "#861 구조화 분석이 데이터 부족·모두 안정권 상태와 합격 가능성·개념 연결을 다루지 않았고, 결과 화면 세션 코멘트는 옛 지시문 그대로였다"
status: resolved
resolution: "[[ISS-0460-ai-analysis-forecast-concept-links-report]]"
related: ["[[ISS-0459-structured-ai-stats-analysis]]", "[[DEC-0259-ai-analysis-server-decides-llm-explains]]", "[[DEC-0260-exam-forecast-score-thresholds]]", "[[ISS-0462-web-wrong-notes-page-404]]"]
source: "_sources/issues/ISS-0460-ai-analysis-forecast-concept-links.md"
---

# ISS-0460: 통계 AI 분석 보강 (과목별 예상 점수, 개념 바로 가기, 빈 데이터 안내)

GitHub #862 (https://github.com/Twin-Fang/passQL/issues/862). [[ISS-0459-structured-ai-stats-analysis]] 의 "알고 남긴 것" 후속.

## 증상
- 데이터가 적거나 모든 토픽이 안정권이면 AI 분석 카드에 한 줄만 남고 다음 할 일이 없음. 프로를 막 산 사람이 처음 보는 화면이 가장 비어 보임.
- 수험생이 가장 궁금한 "지금 합격선인지"를 보여 주지 않음.
- AI 가 짚은 헷갈리는 개념에서 공부로 바로 이어지지 않음.
- AI 분석은 최근 90일, 통계 화면 토픽 표는 최근 7일 기준이라 같은 토픽 숫자가 달라 보임.
- 결과 화면(웹) 세션 AI 코멘트는 옛 지시문 그대로라 일반적인 문장.

## 재현 조건
프로(결제 꺼짐이면 전원) 회원이 통계 화면을 열 때, 특히 푼 문제가 적거나 모든 토픽 정답률이 높을 때. 결과 화면 세션 코멘트는 세트를 끝낼 때.

## 조사 기록
- 2026-11-07: 이슈 본문 제안 — 과목별 예상 점수·과락 판정(서버 계산), 개념 단원 바로 가기, 반복 오답, 데이터 부족·안정권 안내, "최근 90일 기준" 표기, 세션 코멘트도 서버 판정 + AI 한 문장. 지시문은 운영 DB 에만.

## 근본 원인
[[ISS-0459-structured-ai-stats-analysis]] 의 구조화 분석이 판정 가능한 상태(약점·불안정)만 다뤘고, 빈 상태·합격 가능성·개념 연결은 범위 밖이었다. 세션 코멘트는 개편 대상에서 빠져 있었다.
