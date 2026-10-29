---
type: completion-report
id: ISS-0112
created: 2026-04-12
topics: [community, design-system]
status: resolved
resolves: "[[ISS-0112-settings-screen-ui-content-boost]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/198"
---

# ISS-0112 완료 리포트: 설정 4개 섹션 재구성, 건의사항 제출·조회 프론트 선행 구현

GitHub #198 작업 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `src/pages/Settings.tsx`: 계정 / 건의사항 / 앱 정보 / 개발자 4개 섹션, stagger 0~6 순차 페이드인.
- 신규 컴포넌트: `SettingsSection.tsx`, `SettingsRow.tsx`, `FeedbackItem.tsx`, `FeedbackForm.tsx`(0/500 카운터, 실패 시 입력 보존 + 인라인 에러 + 재시도), `FeedbackList.tsx`.
- 신규 API·훅: `src/api/feedback.ts`(`submitFeedback`, `fetchMyFeedback`), `src/hooks/useFeedback.ts`(404 → 빈 목록 fallback), `src/hooks/useOnline.ts`. `src/types/api.ts`에 Feedback 타입. 백엔드 요청 명세 `docs/issues/feedback-api-spec.md`.
- FeedbackStatus 표시: `PENDING` 노란 pill, `REVIEWED` 인디고 pill, `APPLIED` 초록 pill.
- 오프라인: 노란 배너, FeedbackForm disabled, FeedbackList ErrorFallback(재시도 없음).
- 개발자 섹션: localStorage 초기화 2단계 확인(1차 "진짜요?", 3초 후 복귀, 2차 `localStorage.clear()` + `window.location.reload()`).
- 검증: `npm run build` 통과, 백엔드 미구현 상태에서 빈 목록 카드 표시.

## 근본 원인 (확정)
원본에 적혀 있지 않다 (UI 개선).

## 재발 방지
리포트 참고사항: 건의사항 백엔드 API(POST /feedback, GET /feedback/me)는 GitHub #200으로 요청. 오프라인 배너 보더·텍스트 색 2종은 디자인 토큰 미등록(추후 tokens.css 추가 필요). 빌드 번들 820kB 경고는 기존 이슈.
이후 GitHub #208이 개발자 섹션을 Easter Egg + `/dev` 페이지로, GitHub #209가 건의사항을 서브페이지로 옮겼다.

## 교훈
논의 기록 없음.
