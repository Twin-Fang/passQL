---
type: completion-report
id: ISS-0090
created: 2026-04-12
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0090-practice-result-screen-redesign]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/161"
---

# ISS-0090 완료 리포트: StepNavigator 헤더 제거, 순차 통계·AI 분석 뱃지·아코디언, 선택지 본문 저장

GitHub #161 리포트 댓글과 "Stable 반영됨" 댓글 기준 (2026-04-12).

## 해결 방법
- `StepNavigator.tsx`: 상단 헤더(홈/뒤로 + "1/3") 제거, 점 인디케이터 상단 이동(`role="tablist"`), 하단 버튼 아이콘 제거, 탭으로 다음 스텝(`target.closest(...)`로 인터랙티브 요소 제외). `.step-slider` + `--step-offset` CSS 변수로 인라인 style 없이 transform.
- 스텝 1: `visibleStats: boolean[]`로 150ms 간격 순차 fade-up, Target/Clock/Timer 아이콘, "평균" → "문제당 평균", `timerIdsRef`로 타이머 정리.
- 스텝 2: Sparkles + "AI 분석" pill 뱃지, `border-l-4 border-brand bg-accent-light/30` 카드.
- 스텝 3: `grid-rows-[0fr] ↔ grid-rows-[1fr]` 아코디언(300ms), 지문(stemPreview) + 내 답(selectedChoiceBody), 정답/오답 모두 "다시 풀기", `find(questionUuid)` 매핑.
- `PracticeQuestionResult.selectedChoiceBody` 추가, 제출 시점에 `choices.find(key)?.body`를 스토어에 저장(제출 응답에 본문이 없어서).
- `practiceStore.ts`: `set()` 콜백에서 클로저 `results` 대신 `s.results` — 연속 클릭 시 결과 누락 버그 수정.

## 근본 원인 (확정)
해당 없음 (디자인 개선). 부수로 Zustand `set()` 클로저 캡처로 인한 결과 누락 race를 고쳤다.

## 재발 방지
리포트 주의사항: `stemPreview`가 결과 카드에서 보이는 최대 지문(전체 stem은 별도 API 없이는 불가). `selectedChoiceBody`는 스토어에만 있고 서버로 보내지 않는다. 탭-투-어드밴스는 `StepNavigator`에만 있어 다른 페이지 재사용 시 확인 필요.

## 교훈
(원본에 없음, 볼트 정리) Zustand `set()` 안에서는 바깥 클로저 값이 아니라 콜백 인자 상태(`s`)를 써야 연속 업데이트가 누락되지 않는다.
