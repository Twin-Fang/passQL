---
type: completion-report
id: ISS-0114
created: 2026-04-13
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0114-ai-report-padding-button-unify]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/205"
---

# ISS-0114 완료 리포트: 패딩을 컨테이너 단일 레이어로, 버튼을 btn-primary 기준으로

GitHub #205 작업 리포트 댓글 기준 (2026-04-13).

## 해결 방법
- `src/pages/PracticeResult.tsx`: `px-4 sm:px-0` → `px-4`.
- `src/components/StepNavigator.tsx`: step 패널 `px-4` 제거(패딩을 부모에 위임), 버튼 래퍼 `px-6` 제거, 다음/마지막 버튼 → `btn-primary w-full`.
- `src/components/PracticeFeedbackBar.tsx`: 다시 풀기 → `btn-primary flex-1`. 계속하기/확인은 정답/오답 초록·빨강을 유지해야 해서 `btn-primary`를 직접 쓰지 못하고 크기만 `h-11 rounded-lg`로 맞춤.
- 검증: step1·step2 좌우 16px, 버튼 정렬선 일치, 피드백바 높이·radius 통일, 모바일/데스크톱 확인.

## 근본 원인 (확정)
컨테이너와 step 패널의 패딩 중복, 버튼 래퍼 추가 패딩, 공통 버튼 클래스 미사용.

## 재발 방지
리포트: `StepNavigator`는 범용 컴포넌트라 내부에서 패딩을 강제하지 않고 사용처에 위임한다. 현재 `PracticeResult`에서만 쓰이며, 다른 화면에 쓸 때는 부모 컨테이너에 `px-4`가 필요.

## 교훈
(원본에 없음, 볼트 정리) 좌우 여백이 의도의 2배면 부모·자식 양쪽에 같은 패딩이 걸렸는지부터 본다.
