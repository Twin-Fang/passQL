---
type: decision
id: DEC-0261
created: 2026-11-07
reviewed: null
topics: [practice, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0461-plan-aligned-options-new-choices-mode]]", "[[ISS-0461-plan-aligned-options-new-choices-mode-report]]", "[[DEC-0251-practice-reuse-random-validated-sets]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
---

# DEC-0261: 앱의 "실전 모드"를 "새 보기로 풀기"(AI 새 보기 / 검증된 보기)로 바꾸고, "실전"은 모의고사에만 쓴다

## 문제 정의 (Context)
"실전 모드"는 실제로 보기를 매번 AI 가 새로 만드는 방식인데 이름 때문에 시간 제한 모의고사로 오해받았고, 풀이 화면에 현재 모드가 보이지 않았다. 무료 회원에게 잠금 안내가 설정 깊은 곳에만 있었다 (GitHub #863, [[ISS-0461-plan-aligned-options-new-choices-mode]]).

## 결정 (Decision)
- 기능 이름 "새 보기로 풀기", 모드 이름 "AI 새 보기"(선택지 생성 모드 `REAL`)·"검증된 보기"(`PRACTICE`).
- "실전"이라는 말은 SQLD 모의고사([[DEC-0264-mock-exam-fixed-rounds-server-judged]], #866)를 위해 남긴다.
- 풀이 화면 보기 위에 현재 방식 칩을 두고, 누르면 시트에서 바꾼다. 무료는 그 시트 안에서 잠금 미리보기를 본다.
- 새 보기 모드는 검증 세트가 있어도 매번 새로 생성한다 — 모드 동작 기준은 [[DEC-0251-practice-reuse-random-validated-sets]] 그대로이고, 앱이 이를 어기던 버그를 고쳤다.
- 혜택 목록 이름도 "새 보기·토픽" ([[DEC-0262-pro-benefits-seven-ad-removal]]).

## 검토한 대안 (Alternatives)
- 이슈 본문은 "예: 새 보기로 풀기"로 이름 후보를 하나만 적었다. 다른 이름 후보 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 이름이 동작을 설명하고, 무료 회원도 풀이 흐름 안에서 잠금 기능을 본다.

**부정**
- 새 보기 모드를 켠 프로는 문제마다 생성 대기와 AI 비용이 생긴다 (리포트 "주의할 점").

## 영향 범위 (Scope)
앱 풀이 화면 모드 칩·보기 방식 시트, 문제 탭, 설정 학습 항목, `pro_benefits.dart` 라벨, 선택지 조회 분기. 서버 모드 값 `PRACTICE`/`REAL` 은 그대로.

## 출처 (References)
- GitHub #863 이슈 본문·리포트 댓글 (2026-11-07), 커밋 fb86aa42
