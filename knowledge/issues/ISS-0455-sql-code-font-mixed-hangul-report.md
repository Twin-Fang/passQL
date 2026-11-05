---
type: completion-report
id: ISS-0455
created: 2026-11-05
topics: [design-system]
status: resolved
resolves: "[[ISS-0455-sql-code-font-mixed-hangul]]"
related: ["[[DEC-0255-code-font-d2coding-subset]]"]
source: "_sources/issues/ISS-0455-sql-code-font-mixed-hangul-report.md"
---

# ISS-0455 완료 리포트: 코드 글꼴을 D2Coding 부분 글꼴로

GitHub #849 리포트 기준 (2026-11-05). PR #850.

## 해결 방법
- 코드 스타일 3종(code, codeCompact, codeEmphasis)을 D2Coding(합자 없는 판)으로 ([[DEC-0255-code-font-d2coding-subset]]).
- 영문·기호·KS X 1001 한글 2,350자 부분 글꼴 (Regular·Bold 8.5MB > 2.7MB).
- 코드 줄 간격을 본문처럼 위아래 반씩.
- JetBrains Mono 는 번들·라이선스 목록에서 뺌 (파일은 레포에 남김).

## 검증
- `flutter analyze` 0건, `flutter test` 104개 통과.
- 시뮬레이터 3안 비교 (지금 / 본문 글꼴 통일 / D2Coding): D2Coding 이 한글·영문 한 글꼴, 정렬 유지.

## 근본 원인 (확정)
한글 없는 코드 글꼴 + 비고정폭 대체 글꼴이 한 줄에 섞였다.

## 재발 방지
- 앱 CLAUDE.md 글꼴 줄에 D2Coding 부분 글꼴 기록.

## 알고 남긴 것
- KS X 1001 밖의 드문 한글은 본문 글꼴로 보인다.
- 선택지 카드 SQL 이 A·B 표시보다 아래에서 시작하는 것은 카드 안쪽 여백 때문 (글꼴 변경 전과 같음).
