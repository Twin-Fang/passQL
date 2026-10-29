---
type: issue
id: ISS-0292
created: 2026-10-15
topics: [design-system]
symptoms: [textScaler 처리 없음, 시스템 글자 크기 최대, 홈 2열 카드 넘침, Semantics 일부만, 히트맵 레이더 차트 스크린리더]
root_cause: "앱에 글자 배율 처리가 없고 Semantics가 일부 컴포넌트에만 있었다"
status: resolved
resolution: "[[ISS-0292-text-scale-accessibility-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/486"
---

# ISS-0292: 앱 글자 크기 확대 대응과 접근성 부족

GitHub #486 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- `textScaler` 처리가 없고 Semantics는 일부 컴포넌트에만 있음.
- 시스템 글자 크기 최대일 때 선택지 카드, 히트맵, 레이더 차트 확인 필요.
- 위치: `app/lib/presentation/design/components/passql_choice_card.dart:34`, `passql_tab_bar.dart:51`.

## 재현 조건
기기 시스템 글자 크기를 크게(최대 접근성 글자) 설정.

## 조사 기록
- 2026-10-15: 제안 — 큰 글자에서 화면별 스모크 확인, 필요한 곳만 상한 또는 줄바꿈, 주요 버튼·카드에 Semantics.

## 근본 원인
frontmatter `root_cause`와 같음.
