---
type: decision
id: DEC-0004
created: 2026-10-22
reviewed: null
topics: [billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0003-free-pro-plan-android-exam-pass]]"]
---

# DEC-0004: 무료/프로 기능 경계 — 무료도 계속 쓸 수 있되 쓸수록 프로가 아쉬운 구조

## 문제 정의 (Context)
수익 구조를 만들면서 무엇을 무료로 두고 무엇을 잠글지 정해야 했다 (GitHub #576).

## 결정 (Decision)
| 기능 | 무료 | 프로 |
|---|---|---|
| 오늘의 문제 | 항상 무료 | ✓ |
| 랜덤 풀기 | 하루 10문제 (KST, 오늘의 문제 제외, 이미 푼 문제는 다시 볼 수 있음) | 제한 없음 (공정 사용 하루 200, 화면에 드러내지 않음) |
| 토픽 골라 풀기, 실전 모드, 약점 추천 | 잠금 | ✓ |
| SQL 직접 실행 | 잠금 | ✓ |
| 선택지 해설 | 판정 한 줄 | 전체 |
| 통계 | 기본 수치 | + 토픽별 약점, AI 코멘트 |
| 출제 경향 | 잠금 | ✓ |
| 커뮤니티 | ✓ | ✓ |
| 개념 학습 | 앞 단원 | 전체 |

잠긴 기능은 숨기지 않고 흐린 미리보기 위에 한 줄 + 버튼(EarLocAlert #294 방식). 체험 기간 없음. 판정은 서버 `FeatureAccessPolicy` 한 곳.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음

**부정**
- 제출 API에는 하루 한도 검사가 없어(스펙대로) choiceSetId만 알면 한도를 넘어 제출 가능 — 사용자 결정으로 남김(#576 리포트).
- 무료 회원 해설 조회에도 AI 해설 생성은 실행된다(응답에서만 뺌) — AI 비용 발생.

## 영향 범위 (Scope)
서버 `FeatureAccessPolicy`·`ProResponseRedactor`·`@RequiresProFeature`, 앱·웹 잠금 UI. 2026-10-23 상품 변경([[DEC-0003-one-and-three-month-pass]])에서도 이 경계는 그대로 유지.

## 출처 (References)
- GitHub #576 이슈 본문 표·리포트, #578 결정 댓글("무료/프로 경계는 #576 표 그대로")
