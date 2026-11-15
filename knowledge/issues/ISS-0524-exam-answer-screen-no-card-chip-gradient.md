---
type: issue
id: ISS-0524
created: 2026-11-16
topics: [design-system, practice]
symptoms: ["가답안 화면 AI 디자인", "카드 형식 싫음", "알약 칩", "보라 그라데이션 공유 카드", "물결 배지 아이콘", "카드 안의 카드", "색 버튼 2개 나란히", "합의율 막대", "가채점 공유 이미지", "exam_answer_share_card", "exam-answer-share.js", "sqld/63"]
root_cause: "가답안·가채점 화면(앱·소개 사이트)이 시험 당일 급히 만들어지며 앱 디자인 원칙(DEC-0116·DEC-0189) 대신 칩·그라데이션·장식 배지·카드 중첩으로 꾸며졌다"
status: resolved
resolution: "[[ISS-0524-exam-answer-screen-no-card-chip-gradient-report]]"
related: ["[[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]", "[[DEC-0116-app-apple-hig-design-system]]", "[[DEC-0189-home-section-layout-single-cta]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]"]
source: "_sources/issues/ISS-0524-exam-answer-screen-no-card-chip-gradient.md"
---

# ISS-0524: 가답안 화면 카드, 칩, 그라데이션을 앱 디자인 기준으로 정리

GitHub #1109 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1109 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1109#issuecomment-6898334844 · PR #1113 (머지) · 소개 사이트 커밋 dd16038 · 릴리스 PR #1115

## 증상
- 회차별 가답안·가채점 화면(앱, 소개 사이트 63회 페이지)이 "AI가 만든 듯한 카드" 모양이었다. 사용자가 이런 카드 형식을 싫어한다고 지적해 시작.
  - 결과 공유 카드의 보라색 그라데이션 머리띠
  - 수집 상태, 참여 수, 갱신 시각, 점수 범위, 상위 %를 모두 알약 칩으로 표시
  - 물결 모양 배지 아이콘, 색 채운 박스 버튼 2개 나란히, 카드 안의 카드
- 소개 사이트도 점수 그라데이션, 보라 번짐 배경의 공유 이미지, 행마다 카드·그림자.

## 재현 조건
앱 홈 > 회차 가답안 진입(회차 요약·내 가채점·가답안 탭·결과 공유), 소개 사이트 `sqld/63/`.

## 조사 기록
- 2026-11-16: 앱 디자인 원칙 [[DEC-0116-app-apple-hig-design-system]](AI 티 없는 HIG 스타일), [[DEC-0189-home-section-layout-single-cta]](구간 + 목록 행, 채운 버튼 하나)과 화면을 대조 > 칩·그라데이션·장식 배지·카드 중첩이 원칙 위반으로 확인.

## 근본 원인
시험 당일 공개 기능(#1075)을 빠르게 내면서 화면이 앱 공용 부품(grouped 목록 행, 의미색 글자, 토큰) 대신 전용 장식으로 만들어졌다.
