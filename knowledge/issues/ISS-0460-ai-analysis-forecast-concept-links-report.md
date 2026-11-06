---
type: completion-report
id: ISS-0460
created: 2026-11-07
topics: [progress-stats, ai]
status: resolved
resolves: "[[ISS-0460-ai-analysis-forecast-concept-links]]"
related: ["[[DEC-0260-exam-forecast-score-thresholds]]", "[[DEC-0259-ai-analysis-server-decides-llm-explains]]"]
source: "_sources/issues/ISS-0460-ai-analysis-forecast-concept-links-report.md"
---

# ISS-0460 완료 리포트: 예상 점수·과락 판정, 개념 바로 가기, 반복 오답, 빈 상태 안내, 세션 코멘트 개편

GitHub #862 리포트 기준 (2026-11-07). 운영 배포 릴리스 #888.

## 해결 방법
- 예상 점수 `ExamForecastCalculator` (서버): 계산·판정·표시 조건은 [[DEC-0260-exam-forecast-score-thresholds]].
- 개념 학습 바로 가기: 열린 단원만 연결.
- 반복 오답: 최근 90일 같은 문제를 2번 이상 틀린 문제가 2개 이상이면 표시.
- 데이터 부족(5문제 이상 푼 토픽 없음): "지금 N/5" 진행 안내 + 랜덤 풀기·토픽 풀기 버튼, LLM 호출 안 함.
- 모두 안정권: 안 푼 토픽 시작 또는 최신 경향 문제 권유.
- "최근 90일 기준" 표기, 실패 상태와 다시 시도, 순서대로 나타나는 애니메이션(동작 줄이기면 멈춤).
- 결과 화면 세션 코멘트 `SessionCommentService`: 새 프롬프트 키 `ai_analysis_session`, 오답 없음·LLM 실패면 서버 문장만 ([[DEC-0259-ai-analysis-server-decides-llm-explains]] 방식을 세션 코멘트에도 적용).
- 웹: [[ISS-0462-web-wrong-notes-page-404]] (#865) 와 합치며 토픽 연습·오답 노트·출제 경향 버튼 모두 유지.

## 검증
- 서버 테스트 101개, 앱 테스트 108개, 웹 lint·테스트·tsc 통과. 앱 카드 8개 상태 라이트·다크, 웹 모바일 폭 확인.
- 운영 DB `ai_analysis_session` v1 등록·활성화, 운영 AI 3건 테스트(조인, 윈도우 함수, 오답 없음 > null).

## 근본 원인 (확정)
구조화 분석의 범위가 판정 가능한 상태로 한정돼 빈 상태·합격 가능성·개념 연결이 없었고, 세션 코멘트는 옛 지시문 방식이었다.

## 재발 방지
- 숫자 판정(예상 점수·과락·반복 오답·빈 상태)은 서버가 하고 LLM 은 한 문장만 쓴다.
- 지시문은 운영 DB 에만 둔다 (레포·이슈에 본문 없음).

## 알고 남긴 것
- 랜덤 풀기는 앱의 기존 10문제 화면을 쓴다. 웹에는 랜덤 풀기·개념 화면이 없어 그 버튼은 숨김.
- 옛 키 `ai_comment` 는 코드가 더 이상 읽지 않고 DB 에만 남아 있음.

## 교훈
빈 상태(데이터 부족·전부 양호)는 기능을 처음 쓰는 사람이 가장 먼저 보는 화면이다. 판정 화면을 만들 때 빈 상태의 다음 행동도 같이 설계한다.
