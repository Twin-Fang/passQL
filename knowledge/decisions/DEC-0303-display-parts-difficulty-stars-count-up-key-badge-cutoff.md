---
type: decision
id: DEC-0303
created: 2026-11-13
reviewed: null
topics: [design-system, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0511-qa-1112-ui-polish-eight]]", "[[ISS-0511-qa-1112-ui-polish-eight-report]]", "[[DEC-0292-stem-table-match-by-name-short-code-caption]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
---

# DEC-0303: 난이도는 아이콘 별 부품 PassqlDifficultyStars, 주요 숫자는 0부터 차오르는 PassqlCountUp, 표 머리 PK·FK는 색 구분 배지로 그리고, 과락 규칙은 경고색 상자 대신 과목별 기준 칸으로 보여 준다

GitHub #1041 (이슈 본문 5~8번, 「시안 8건」 댓글 ⑤~⑧, 완료 보고서).

## 문제 정의 (Context)
난이도가 글자 `★★★☆☆`라 글꼴마다 모양·크기가 달랐고, 점수·크레딧 숫자는 바로 찍혔으며, 표 머리 `PK`·`FK`는 이름 뒤 글자였고, 모의고사 과락 안내는 노란 경고 상자(삼각 아이콘)라 오류처럼 보였다.

## 결정 (Decision)
- **난이도 별:** 공통 부품 `PassqlDifficultyStars`(채운 별 주황, 빈 별 회색)로 풀이 머리·홈 추천·프로필 3곳 통일, 글자 별 함수 제거. 웹·관리자 별과 같은 뜻.
- **카운트업:** 공통 부품 `PassqlCountUp` — 0부터 700ms(토큰의 점수 차오름 그대로), 값이 바뀌면 이전 값에서 이어짐, 동작 줄이기면 바로 최종값. 적용: 모의고사 총점·크레딧 잔액.
- **PK·FK:** 표 머리 이름 뒤 작은 배지(PK 강조색, FK 주의색), 반경 토큰 `keyBadge`. 표 모양 규칙(컬럼 이름 + PK, FK 표시, [[DEC-0292-stem-table-match-by-name-short-code-caption]])은 그대로이고 표기 방식만 배지.
- **과락:** 모의고사 회차 목록 머리의 노란 경고 상자 > `과목별 과락 기준` 카드 + 과목 칸 2개(`8점 이상`·`32점 이상`, 문항 수·만점). "미만이면 불합격" 대신 넘어야 할 점수로 표기. 기준 값은 [[DEC-0264-mock-exam-fixed-rounds-server-judged]] 그대로.

## 검토한 대안 (Alternatives)
- 난이도 B안 막대 5칸: 깔끔하지만 웹(StarRating)·관리자 화면의 별과 달라짐(시안 댓글 이미지 설명).
- 카운트업 B안 자리별 굴러감: 화려하지만 자리 수가 바뀌는 값(9 > 10)에서 어색하고 코드가 큼(시안 댓글 이미지 설명).
- 과락 A안 회색 정보 한 줄: 차분하지만 과목별 실제 기준 점수(8점·32점)가 안 보임(시안 댓글 이미지 설명).
- PK·FK 밑줄 PK·점선 FK: 교재 관례지만 범례가 필요하고 좁은 화면에서 실선·점선 구분이 어려움(시안 댓글 이미지 설명). 지금 글자 표기는 이름의 일부처럼 보여 바꿈.

## 결과 (Consequences)
**긍정**
- 같은 표시가 부품 하나로 모여 화면마다 모양이 같다.

**부정**
- 논의 기록 없음. 실기기 확인 전(시뮬레이터 실측 못 함). 다크에서 과락 칸·미리보기 배경이 검게 뜨던 문제는 `fill`로 바꿔 고쳤다(리포트).

## 영향 범위 (Scope)
`app/lib/presentation/design/` 부품 `PassqlDifficultyStars`·`PassqlCountUp`, 반경 토큰 `keyBadge`, 지문 표 머리, 풀이 머리·홈 추천·프로필 통계, 모의고사 결과 총점·회차 목록 머리, 크레딧 잔액.

## 출처 (References)
- GitHub #1041 이슈 본문, 시안 댓글 ⑤~⑧, 완료 보고서 댓글, PR #1042
- [[ISS-0511-qa-1112-ui-polish-eight-report]]
