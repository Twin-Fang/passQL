---
type: issue
id: ISS-0544
created: 2026-11-18
topics: [design-system, home, practice]
symptoms: ["왼쪽 세로 막대", "왼쪽 선 콜아웃", "PassqlCallout", "AI 티", "강조 상자", "운영 안내 보라 상자", "학습 가이드 여러 개", "학습 가이드 중복", "StudyGuideEntryRow", "홈 구간 통일성", "최근 회차 이야기 정렬", "PassqlGroupedSection 가운데 정렬", "회차 난이도 딱딱함"]
root_cause: "왼쪽 막대가 공통 강조 상자 부품과 디자인 문서 규격에 들어 있었고, 학습 가이드 입구가 4곳(문제 탭 2번)에 흩어졌으며, 목록 묶음 카드 안 Column 기본값 center 로 글자만 쌓은 행이 가운데로 몰렸다"
status: resolved
resolution: "[[ISS-0544-callout-no-left-bar-roadmap-home-entry-report]]"
related: ["[[DEC-0346-callout-no-left-accent-bar]]", "[[DEC-0347-roadmap-entry-home-only-more-practice-group]]", "[[DEC-0331-study-guide-four-stages-progress-counts-study]]", "[[ISS-0521-sqld-exam-guide-and-yearly-stats]]"]
source: "_sources/issues/ISS-0544-callout-no-left-bar-roadmap-home-entry.md"
---

# ISS-0544: 강조 상자 왼쪽 선(AI 티), 학습 가이드 입구 중복, 홈 구간 불통일, 회차 목록 가운데 정렬 (#1158)

GitHub: https://github.com/Twin-Fang/passQL/issues/1158

## 증상
- 가답안 운영 안내 등 보라 상자 왼쪽에 세로 선. 사용자: "보라색 카드 왼쪽에 선 없애랬잖아 AI티 내지말라니까 디자인 시스템안봐?"
- 학습 가이드가 문제 탭에 여러 개 뜨고, 무엇을 하는 기능인지 안 보임. 홈은 행 하나짜리 구간 3개가 제목 있음·없음 제각각.
- SQLD 알아보기 최근 회차 이야기 행마다 들여쓰기가 달라짐, 난이도가 글로만 있어 딱딱함.

## 재현 조건
가답안 화면·개념 함정 카드(강조 상자), 프로 사용자 문제 탭 주제별 보기(학습 가이드 2행), SQLD 알아보기 역대 통계 탭.

## 조사 기록
- 2026-11-18: `PassqlCallout` 에 `Border(left:)` 막대, `Design.md` 도 막대를 규격으로 적음 > 10곳 공통. 문제 탭 `_RandomPracticeSection`·`_CommonShortcutSection` 둘 다 입구 행 포함. `PassqlGroupedSection` 카드 안 `Column` crossAxisAlignment 미지정.

## 근본 원인
디자인 시스템 원본에 금지 모양이 남아 있었고 막는 규칙 테스트가 없었다. 입구는 기능 추가 때 화면마다 붙였다.
