---
type: completion-report
id: ISS-0473
created: 2026-11-07
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0473-solving-memo-pen-toggle]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/904"
---

# ISS-0473 완료 리포트: 디자인 시스템 메모 층(끄면 터치 통과), 문항별 기기 메모리 보관, 앱과 웹 같은 동작

GitHub #904 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/904#issuecomment-6702224320). PR #910 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0473-solving-memo-pen-toggle-report.md`(로컬).

## 해결 방법
- 앱: 디자인 시스템 `PassqlMemoScope`, `PassqlMemoCanvas`, `PassqlMemoController`(패키지 없이 `CustomPainter`), 펜 버튼(메모 있으면 빨간 점), 도구 막대(펜, 형광펜, 지우개, 되돌리기, 빨강, 파랑, 검정, 완료), 위쪽 안내. 켜면 한 손가락 그리기, 두 손가락 스크롤. 끄면 `IgnorePointer`로 터치가 아래 문항으로. 토큰 `memoInkBlue`, SVG 경로 해석 `passqlSvgPath` 공통화. 적용: 모의고사, 토픽 연습, 오늘의 세트, 랜덤 풀기.
- 웹: `SolvingMemoBoard`, `SolvingMemoCanvas`, `SolvingMemoControls`, `useSolvingMemo`(Pointer Events로 마우스, 펜, 터치). 끄면 캔버스 `pointer-events` 없음. 펜 색 토큰 `--color-memo-ink-*`, `--color-memo-highlighter`(앱 값 대조 테스트). 적용: 모의고사, 연습 세트, 데일리 세트, 추천 문제.
- 저장: 문항별, 내용과 함께 스크롤, 기기 메모리에 그 응시 동안만, 서버 저장 없음.

## 검증
- 앱 `flutter analyze` 0건, `flutter test` 124개(켬: 보기 탭과 스크롤 없이 획만, 끔: 보기 탭과 세로 스크롤 정상 위젯 테스트).
- 웹 lint 0, vitest 31개, `tsc` 통과, 브라우저 실측(끔: 보기 B 선택, 휠 스크롤 68px, 메모 점).
- 코드 점검 새 위반 0.

## 근본 원인 (확정)
해당 없음 (기능 요청).

## 재발 방지
- 끈 상태의 터치 통과는 앱 `IgnorePointer`, 웹 `pointer-events` 하나에 걸려 있다. 메모 층을 고칠 때 끔 상태 위젯 테스트를 같이 돌린다.
- 펜 색은 앱 토큰과 웹 토큰 두 곳, 대조 테스트로 묶임.

## 남은 일
- 실기기 손가락 그리기와 iOS 뒤로 밀기 충돌 확인(배포 빌드).
- 회전, 글자 크기 변경으로 문항 배치가 바뀌면 메모가 글자와 어긋날 수 있음(화면 좌표 저장의 한계).

## 교훈
풀이 화면 위에 겹치는 기능은 "끈 상태에서 아무것도 바뀌지 않음"을 위젯 테스트로 먼저 고정해야 기존 흐름을 깨지 않는다.
