---
type: decision
id: DEC-0167
created: 2026-10-21
reviewed: null
topics: [design-system, home]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0356-home-questions-tab-restructure]]", "[[ISS-0356-home-questions-tab-restructure-report]]"]
---

# DEC-0167: 하단 탭 5개는 유지하고 아이콘 아래에 이름(홈 / 문제 / 토론 / 기록 / MY)을 표시한다

## 문제 정의 (Context)
하단 탭이 아이콘만 표시돼 의미를 추측해야 했다. 기능 진입 경로 점검에서 묻힌 기능이 확인됐다 (GitHub #574 범위 확장, 2026-10-21).

## 결정 (Decision)
- 탭 5개와 경로는 그대로 두고 아이콘 + 이름을 표시한다: 홈 / 문제 / 토론 / 기록(구 통계) / MY(구 설정). 탭 바 높이 49.

## 검토한 대안 (Alternatives)
- 탭을 4개로 합치는 안: 리포트 "설정까지 세 번 탭해야 하고 경로 이전 위험이 있어 택하지 않았다."
- 아이콘만 유지: 버린 이유는 "아이콘만 표시(의미를 추측해야 함)"로 적혀 있다.

## 결과 (Consequences)
**긍정**
- 경로를 유지해 푸시 링크와 딥링크에 영향이 없다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
앱 하단 탭 바(셸 라우터), 탭 이름 표기(기록·MY).

## 출처 (References)
- GitHub #574 범위 확장 댓글·리포트 댓글(2026-10-21)
- 기존 볼트 결정과 어긋남: DEC-0101(하단 탭 바는 글자 없이 아이콘만), DEC-0018(`홈 / 문제 / 통계 / 설정` 4탭). 원본은 이들을 대체한다고 명시하지 않았다.
- [[ISS-0356-home-questions-tab-restructure]]
