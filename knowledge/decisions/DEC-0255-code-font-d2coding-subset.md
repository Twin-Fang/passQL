---
type: decision
id: DEC-0255
created: 2026-11-05
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0455-sql-code-font-mixed-hangul]]"]
---

# DEC-0255: 코드 글꼴은 한글까지 고정폭인 D2Coding 부분 글꼴을 쓴다

## 문제 정의 (Context)
한글이 섞인 SQL 이 두 글꼴로 갈라져 읽기 어려웠다 (GitHub #849, [[ISS-0455-sql-code-font-mixed-hangul]]).

## 결정 (Decision)
- 코드 글꼴은 D2Coding(네이버, OFL, 합자 없는 판) Regular·Bold.
- 영문·기호·KS X 1001 한글 2,350자만 남긴 부분 글꼴로 싣는다 (앱 크기).
- 그 밖의 드문 글자는 Pretendard 로 대체한다.

## 검토한 대안 (Alternatives)
- 본문 글꼴(Pretendard)로 통일: 고르게 읽히지만 고정폭이 아니라 들여쓰기·결과 주석 정렬이 깨져 버렸다.
- 지금 글꼴 유지 + 크기·줄 간격 조정: 두 글꼴이 섞이는 원인이 남아 버렸다.
- 원본 D2Coding 전체: 8.5MB 로 앱 크기가 크게 늘어 버렸다.

## 결과 (Consequences)
**긍정**
- 한글 섞인 SQL 이 한 글꼴·고정폭으로 고르게 읽힌다.

**부정**
- 드문 한글 음절은 본문 글꼴로 보인다.

## 영향 범위 (Scope)
`PassqlTypography.code/codeCompact/codeEmphasis`, `pubspec.yaml` fonts, `bundled_font_licenses.dart`, `assets/fonts/D2Coding-*`.

## 출처 (References)
- GitHub #849 PR #850 (2026-11-05)
- 이슈: [[ISS-0455-sql-code-font-mixed-hangul]]
