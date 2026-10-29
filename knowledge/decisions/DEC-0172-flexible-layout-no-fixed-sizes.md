---
type: decision
id: DEC-0172
created: 2026-10-24
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0363-app-wide-ui-ux-cleanup]]", "[[ISS-0363-app-wide-ui-ux-cleanup-report]]"]
---

# DEC-0172: 기기 크기·글자 크기 대응은 고정 높이·폭 없이 내용에 맞춰 자라는 레이아웃으로, 기기별 분기는 쓰지 않는다

## 문제 정의 (Context)
기기 크기·글자 크기에 따른 배치를 기준 없이 잡아 공간이 남거나 모자랐다. 사용자 평가: "기기 크기와 상관없이 잘 넣어야 하는데 지금 이런 기준으로 구성을 제대로 못 해 준다" (GitHub #602).

## 결정 (Decision)
이슈 본문 "2. 기기 크기·글자 크기 대응 기준 (모든 화면 공통)":
- 글자나 영역에 고정 높이·폭을 쓰지 않는다. 내용에 맞춰 자라는 레이아웃(`Flexible`, `Wrap`, 최소·최대 제약)을 쓴다.
- 두 카드를 나란히 놓을 때 한쪽 높이에 억지로 맞추지 않는다.
- 가로가 좁으면 줄바꿈하거나 아이콘만 남기는 대체 규칙을 정하고, 한 줄에 요소를 4개 이상 넣지 않는다.
- 태블릿·폴더블은 본문 폭을 제한하고 가운데 정렬한다.
- 검수 매트릭스: 작은 폰(폭 375pt 이하) / 일반 / 큰 폰, 글자 기본·접근성 XL, 라이트·다크, Android 소형 에뮬레이터.
리포트: 좁은 카드와 큰 글자는 `Expanded`·`Flexible`·`Wrap`·`FittedBox(scaleDown)`로 풀고 기기별 분기는 쓰지 않았다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 폭 320/375/430pt × 글자 1.0/1.5/2.0배 조합에서 넘침 없음(검사한 화면 기준).

**부정**
- 논의 기록 없음. (이슈 본문은 "고정 높이로 텍스트 영역 제한 금지" 구조 규칙 테스트 추가를 검토 항목으로만 남겼다.)

## 영향 범위 (Scope)
앱 화면 전반, 특히 홈 2열 카드·풀이 결과 하단 줄. 이틀 전(2026-10-22) GitHub #574의 `PassqlCard.shouldChildFillHeight`(2열 높이 맞춤)와 유형 카드 고정 높이 상수는 이 기준과 긴장 관계가 있다(원본에 없음, 볼트 정리).

## 출처 (References)
- GitHub #602 이슈 본문, 크기 검증 댓글·리포트 댓글(2026-10-24)
- [[ISS-0363-app-wide-ui-ux-cleanup]]
