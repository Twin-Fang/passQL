---
type: decision
id: DEC-0154
created: 2026-10-18
reviewed: null
topics: [practice, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0330-stale-explanation-sheet-empty-result]]", "[[ISS-0330-stale-explanation-sheet-empty-result-report]]", "[[DEC-0147-keep-explanation-sheet-while-solving]]"]
---

# DEC-0154: 풀이 중 "다음"으로 넘어가면 해설 시트를 닫는다 (해설함·백그라운드 조회는 유지)

## 문제 정의 (Context)
GitHub #521 "해설 보며 계속 풀기"가 다음 문제로 가도 시트를 유지하도록 설계돼, 이전 문제 해설 시트가 다음 문제의 보기와 제출 버튼을 가렸다 (GitHub #538).

## 결정 (Decision)
"다음"에서 해설 시트를 닫는다. 해설함과 백그라운드 재조회는 유지하고 상단 해설함 아이콘으로 다시 열 수 있다. 원본은 이 변경이 #521의 "다음 문제로 가도 시트 유지" 설계를 바꾼 것이라고 적었다([[DEC-0147-keep-explanation-sheet-while-solving]]).

## 검토한 대안 (Alternatives)
- 시트를 닫는 대신 상단으로 접는 방식: 해설을 본 채로 다음 문제를 풀고 싶다는 요구가 다시 나오면 따로 설계할 거리로 남겼다(채택하지 않은 이유는 원본에 없음).

## 결과 (Consequences)
**긍정**
- 이전 문제 해설이 현재 풀이와 섞이지 않는다(2026-10-26 시뮬레이터 확인).

**부정**
- 해설을 보며 다음 문제를 푸는 흐름은 해설함 아이콘으로 다시 열어야 한다.

## 영향 범위 (Scope)
앱·웹 풀이 화면 "다음" 동작, 해설 시트·패널.

## 출처 (References)
- GitHub #538 보고 댓글 (2026-10-18), 확인 리포트 (2026-10-26)
- [[ISS-0330-stale-explanation-sheet-empty-result]]
