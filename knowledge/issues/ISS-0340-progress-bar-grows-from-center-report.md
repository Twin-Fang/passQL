---
type: completion-report
id: ISS-0340
created: 2026-10-21
topics: [design-system]
status: resolved
resolves: "[[ISS-0340-progress-bar-grows-from-center]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/552"
---

# ISS-0340 완료 리포트: 진행 막대 폭을 부모 전체로 고정

GitHub #552 리포트 댓글(`## 개요`, 2026-10-21) 기준. 커밋 6d917262, v1.27.0.

## 해결 방법
`app/lib/presentation/design/components/passql_progress_bar.dart`의 바깥 `SizedBox`에 `width: double.infinity`. 공통 컴포넌트 한 곳 수정으로 사용처 5곳에 함께 반영.

## 근본 원인 (확정)
폭 미지정 Stack이 가운데 정렬 Column 안에서 채움 폭만큼만 잡혔다.

## 재발 방지
- 검증: 위젯 측정 300 폭에서 트랙 300·채움 84(28%), iOS 렌더 트리 트랙 338pt 전체 폭.
- 주의: 폭이 무한인 자리(가로 Row 안에서 `Expanded` 없이)에 넣으면 레이아웃 오류. `bar_chart_section`처럼 `Expanded`로 감싸 쓴다. 풀이 상단 막대는 "제출한 문제 수" 기준이라 1번 제출 전 0이 정상.

## 교훈
(원본에 없음, 볼트 정리) 공통 막대·트랙 컴포넌트가 가운데서 자라면 폭 제약(`double.infinity` 또는 `Expanded`) 누락부터 본다.
