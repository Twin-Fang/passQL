---
type: issue
id: ISS-0123
created: 2026-04-13
topics: [practice, design-system]
symptoms: ["지문 카드", "선택지 카드 구분 안 됨", BookOpen, QuestionDetail, "지문이 첫 번째 선택지처럼"]
root_cause: "펼친 지문 카드가 선택지 카드와 같은 흰 카드 스타일이고 아이콘이 접힌 상태에서만 보였다"
status: resolved
resolution: "[[ISS-0123-stem-card-choice-card-distinction-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/224"
---

# ISS-0123: 지문 카드와 선택지 카드 시각적 구분

GitHub #224 (원본: 이슈 본문, 제안 댓글, 작업 리포트 댓글).

## 증상
`QuestionDetail`에서 지문 카드를 펼치면 선택지 카드와 디자인이 같아 구분이 안 되고, 펼친 상태에선 아이콘도 사라져 지문이 첫 번째 선택지처럼 보인다.

## 재현 조건
문제 풀기 화면에서 지문 카드 펼치기.

## 조사 기록
- 2026-04-13: 이슈 등록. 제안: 지문 카드 상단 작은 "문제" 라벨 상시 노출, 그 외는 UI 브레인스토밍 필요.
- 2026-04-13: 댓글 제안 — Table 왼쪽에 Table 아이콘이 있는 것처럼 문제에도 문제 아이콘 추가.

## 근본 원인
지문 카드와 선택지 카드의 동일 스타일, 펼침 상태의 시각적 단서 부재.
