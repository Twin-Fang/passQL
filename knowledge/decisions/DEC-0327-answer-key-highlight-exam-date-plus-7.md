---
type: decision
id: DEC-0327
created: 2026-11-16
reviewed: null
topics: [home, practice, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0534-intro-site-past-exam-preview-study-guides]]", "[[ISS-0535-past-exam-restored-rounds]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[DEC-0315-exam-answer-page-concept-line-no-original]]", "[[DEC-0317-site-answer-key-fallback-operator-draft]]", "[[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]"]
---

# DEC-0327: 가채점 진행 중 강조(사이트 메뉴·첫 화면 띠, 앱 홈 가답안 카드)는 시험일 + 7일까지만 두고, 회차 가답안 페이지는 지난 회차로 계속 열람하게 둔다

GitHub #1079·#1088 (공유 보고서 댓글), 2026-11-16 사용자 지시.

## 문제 정의 (Context)
63회 가답안·가채점([[ISS-0520-sqld-round-answer-key-omr-grading]])을 시험 당일 사이트 메뉴·첫 화면 띠와 앱 홈 가답안 구간으로 강조했다. 앱 홈 구간은 "수집 중·공식 반영 기간"에 보였고(ISS-0520 기록), 사이트 강조는 끝나는 시점이 정해져 있지 않았다. 기출 복원 메뉴·문항 연결을 앞에 두려면 강조를 언제 내릴지 정해야 했다.

## 결정 (Decision)
- 소개 사이트의 가채점 강조(상단 메뉴·첫 화면 띠)는 **시험일 + 7일까지만**. 그 뒤에는 문항별 앱 연결이 앞에 온다.
- 앱 홈 가답안 카드도 **시험일 + 7일까지만** 노출한다(사이트 강조 기간과 같은 기준).
- 회차 가답안 페이지(`sqld/<회차>/`)와 앱 회차 화면은 내리지 않고 지난 회차로 계속 열람할 수 있게 둔다.

## 검토한 대안 (Alternatives)
- 강조 기간 길이: 사용자가 "한 일주일정도로만"이라고 정했다(2026-11-16). 다른 기간 후보는 논의 기록 없음.
- 기간이 지나면 회차 페이지를 내리기: 다른 사이트도 옛 기출을 계속 열람시키는 점을 근거로 택하지 않았다(2026-11-16 대화). 그 밖의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 시험 직후 1주는 가채점이 눈에 띄고, 그 뒤 메뉴·홈 자리가 기출 복원 등 상시 기능으로 돌아간다. 지난 회차 페이지는 검색 유입 자료로 남는다.

**부정**
- 공식 정답 발표가 7일보다 늦으면 발표 시점에 홈·메뉴 강조가 이미 내려가 있다 — 그 경우 대응은 논의 기록 없음.

## 영향 범위 (Scope)
앱 홈 가답안 카드 노출 조건(PR #1124), 소개 사이트 상단 메뉴·첫 화면 띠(#1088 사이트 배포). 가답안 데이터·채점 규칙([[DEC-0320-exam-answer-disputed-shows-operator-candidate]]), 화면 모양([[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]])은 범위 밖.

## 출처 (References)
- GitHub #1079 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1079#issuecomment-6903849347 ("앱 홈 가답안 카드: 시험일 + 7일까지만 (사이트 강조 기간과 같음)", "가채점 강조(메뉴·첫 화면 띠)를 시험일 + 7일로 단축")
- 2026-11-16 사용자 대화("한 일주일정도로만") — 세션 대화, 원문 미보존

## W4 검사
#1075 관련 활성 결정과 대조 — 충돌 없음.
- [[DEC-0315-exam-answer-page-concept-line-no-original]](문항 형태·면책·게시 중단): 노출 기간을 정하지 않는다. 회차 페이지는 계속 열람하므로 그대로 유효.
- [[DEC-0317-site-answer-key-fallback-operator-draft]](서버 실패 시 스냅샷): 페이지 동작 규칙이라 대상이 다르다.
- [[DEC-0320-exam-answer-disputed-shows-operator-candidate]]·[[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]: 정답 판정·화면 모양이라 대상이 다르다.
- 앱 홈 "수집 중·공식 반영 기간" 노출은 ISS-0520 의 구현 기록이며 결정 노트가 아니다. 이 결정이 그 기간에 상한(시험일 + 7일)을 둔다.
