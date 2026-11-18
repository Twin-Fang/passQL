---
type: completion-report
id: ISS-0544
created: 2026-11-19
topics: [design-system, home, practice]
status: resolved
resolves: "[[ISS-0544-callout-no-left-bar-roadmap-home-entry]]"
related: ["[[DEC-0346-callout-no-left-accent-bar]]", "[[DEC-0347-roadmap-entry-home-only-more-practice-group]]"]
source: "_sources/issues/ISS-0544-callout-no-left-bar-roadmap-home-entry-report.md"
---

# ISS-0544 완료 리포트: 강조 상자 막대 제거·규칙 테스트, 합격 로드맵 홈 한 곳, 더 풀기 묶음, 회차 난이도 아이콘 (#1158)

보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1158#issuecomment-6986754994 · 커밋 3897e226

## 해결 방법
- `PassqlCallout`: 옅은 의미색 바탕 + 둥근 모서리 + 원형 아이콘. 규칙 테스트가 `lib/presentation` 전체(디자인 시스템 포함)의 왼쪽 테두리를 막음 — [[DEC-0346-callout-no-left-accent-bar]].
- 학습 가이드 > 합격 로드맵, 입구 홈 한 곳, 부제에 지금 단계. 홈 랜덤 풀기·모의고사·로드맵을 「더 풀기」 구간 하나로 — [[DEC-0347-roadmap-entry-home-only-more-practice-group]].
- `PassqlGroupedSection` 행 stretch. 서버 `RoundNote.difficultyLevel`(1~3) 추가 > 행 왼쪽 난이도 타일(쉬움 웃음·보통 게이지·어려움 불꽃), 앱 기본값 0 이면 숨김.

## 근본 원인 (확정)
조사 기록과 같음.

## 재발 방지
- 규칙 테스트(왼쪽 막대 금지), Design.md 5.5 한 줄. `flutter analyze` 무이슈, `flutter test` 198개, 계약 테스트 갱신, 위젯 코드 렌더 라이트·다크 캡처(시뮬레이터는 메모리 부족).

## 교훈
사용자가 금지한 모양은 화면이 아니라 디자인 시스템 원본과 문서에서 먼저 지우고 테스트로 막는다.
