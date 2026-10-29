---
type: completion-report
id: ISS-0339
created: 2026-10-21
topics: [practice]
status: resolved
resolves: "[[ISS-0339-feedback-bar-covers-choices]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/551"
---

# ISS-0339 완료 리포트: 하단 바 높이를 뺀 스크롤 공통 함수 `revealAboveBottomBar`

GitHub #551 리포트 댓글(`## 개요`, 2026-10-21) 기준. 커밋 28a561d5, v1.27.0.

## 해결 방법
- `app/lib/presentation/widgets/question/reveal_above_bottom_bar.dart`: `revealAboveBottomBar`(보이는 영역 = 뷰포트 - MediaQuery 하단 여백), `RevealAboveBottomBarOnTrigger`(false > true 전환 시 실행).
- `question_sections.dart`: 보기 카드를 트리거로 감싸 채점 직후 정답 보기에서 실행.
- `question_solving_body.dart`: 실행 결과 자동 스크롤을 `Scrollable.ensureVisible` 대신 공통 함수로.
- `ai_explanation_preview_card.dart`: 미리보기 본문 최소 높이 = 판정 1줄 + 근거 2줄(글자 크기 설정 반영) → 피드백 바 높이를 문제마다 같게.
- 이미 보이면 움직이지 않고, 대상이 보이는 영역보다 크면 위 끝을 우선한다.

## 근본 원인 (확정)
하단 바 높이는 Scaffold 안쪽 `MediaQuery.paddingOf(context).bottom`에 이미 더해져 있는데, `ensureVisible`은 이를 빼지 않고 뷰포트 끝에 맞췄다.

## 재발 방지
- 검증: iOS 시뮬레이터 2026-10-21 오늘의 세트 2번에서 정답 B가 피드백 바 바로 위, `flutter test` 528건 통과.
- 주의: 풀이 화면 구조를 `extendBody` 없이 바꾸거나 본문 스크롤뷰가 MediaQuery 여백을 제거(padding null인 ListView 등)하면 계산이 달라진다. 해설이 한 줄이면 카드 아래가 비어 보이는 것은 의도.

## 교훈
(원본에 없음, 볼트 정리) `extendBody` 화면에서 자동 스크롤이 하단 바 뒤에서 멈추면 하단 여백(MediaQuery 하단 padding)을 빼고 계산하는지부터 본다.
