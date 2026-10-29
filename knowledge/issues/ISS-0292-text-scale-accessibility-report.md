---
type: completion-report
id: ISS-0292
created: 2026-10-15
topics: [design-system]
status: resolved
resolves: "[[ISS-0292-text-scale-accessibility]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/486"
---

# ISS-0292 완료 리포트: 전역 글자 배율 1.4배 상한(`PassqlTextScaleLimit`)과 차트 스크린리더 요약

GitHub #486 구현 보고서 댓글 기준 (2차 통합본).

## 해결 방법
- 시스템 글자 배율을 앱 전역 한 곳(`PassqlTextScaleLimit`, `MaterialApp.builder`)에서 1.4배로 제한: 2배일 때 홈 2열 카드 넘침 방지.
- 히트맵·레이더 차트에 스크린리더 요약 문구.
- 큰 글자 화면별 스모크 테스트.
- 검증: `flutter analyze` 경고 0, `flutter test` 292개 통과, 큰 글자·최대 접근성 글자에서 홈·문제 풀이 촬영(라이트·다크).

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
원본에 별도 언급 없음. (이슈 본문은 "필요한 곳만 상한 또는 줄바꿈"을 제안했고, 구현은 전역 한 곳 상한으로 했다. 그 선택의 이유는 "2배일 때 홈 2열 카드 넘침 방지" 외에 원본에 없다.)

## 교훈
(원본에 없음, 볼트 정리) 큰 글자에서 레이아웃이 깨지면 `PassqlTextScaleLimit` 상한(1.4배)이 적용되는 범위 안인지부터 본다.
