---
type: decision
id: DEC-0283
created: 2026-11-12
reviewed: null
topics: [practice, billing, ads]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0488-free-practice-reward-flow]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]", "[[DEC-0271-daily-limit-judged-in-submit-record-tx]]"]
---

# DEC-0283: 무료 랜덤 풀이는 끊기지 않게 이어 풀고, 한도에 닿으면 보상(광고 > 오늘의 세트)을 먼저, 이용권은 맨 아래 한 줄로 보여 준다

## 문제 정의 (Context)
결제를 켠 뒤 사용자가 직접 풀어 보며 "flow가 말이 안 된다", "과금 유도를 이상하게 하지 말고 보상 주는 것을 제대로 예쁘게"라고 평가했다 (GitHub #963). 랜덤 풀이는 10문제 묶음이라 끊겼고, 남은 한도가 안 보였고, 한도에 닿으면 구매 권유 시트가 먼저 떠서 광고 버튼은 네 번째 블록에 있었다.

## 결정 (Decision)
- 랜덤 풀이는 10문제 묶음 없이 이어 푼다(남은 문제가 2개 이하면 다음 묶음을 미리 받음). 나가면 "이번에 푼 문제" 요약.
- 홈 랜덤 줄과 풀이 상단에 "오늘 남은 N문제"를 늘 보여 준다(2문제 이하면 경고 색).
- 한도 화면(시안 A안): 위에서부터 제목 > 광고 보고 5문제 더(주 버튼) > 오늘의 세트(+5, +5) > 맨 아래 plain 한 줄 "광고 없이 제한 없이 풀기 (PRO) ›". 풀이 화면 안 본문과 진입·제출 시트가 같은 화면.
- 보상을 받으면 "+N문제" 팝과 남은 수 게이지 연출.
- 한도 화면의 "오늘의 세트 풀러 가기"는 풀이 흐름 안이면 현재 흐름을 세트로 교체한다.

## 검토한 대안 (Alternatives)
- 시안 B안(남은 수를 크게, 방법은 목록): 사용자가 추천안으로 맡겨 A안을 골랐다(설계자 추천: 보상 먼저·결제 억지 유도 금지에 가장 맞음).
- 10문제 묶음 유지 + 묶음 사이 결과 화면: 흐름이 끊긴다는 사용자 지적으로 버렸다.

## 결과 (Consequences)
**긍정**
- 한도에 닿아도 막다른 길이 없다(광고·세트·이용권 모두 갈 곳).
- 보상이 눈에 보여 오늘의 세트 참여 동기가 생긴다.

**부정**
- 랜덤 완료 분석 이벤트가 10문제 완료 대신 나갈 때 찍혀 대시보드 해석이 바뀐다.
- 오늘의 세트 결과의 보상 연출 때문에 그 화면의 스토어 평가 요청이 거의 나가지 않는다(제품 결정 필요).

## 영향 범위 (Scope)
- 앱: `presentation/flows/question_flow.dart`·`random_practice_flow.dart`·`continuous_question_loader.dart`, `pages/questions/chapter_page.dart`·`random_practice_summary_page.dart`, `widgets/practice/`(남은 수 알약, `openRandomPractice`, 한도 화면·시트·세트 카드), `design/components/passql_reward_celebration.dart`, `widgets/daily_set/daily_set_bonus_card.dart`.
- 서버: `RandomPracticeService`(안 푼 문제 먼저).

## 출처 (References)
- GitHub #963 완료 보고: https://github.com/Twin-Fang/passQL/issues/963#issuecomment-6803089405
- 시안: 한도 화면 A안·B안 (로컬 시안, PR #964)
