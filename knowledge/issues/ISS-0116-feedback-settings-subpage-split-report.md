---
type: completion-report
id: ISS-0116
created: 2026-04-13
topics: [community, design-system]
status: resolved
resolves: "[[ISS-0116-feedback-settings-subpage-split]]"
related: ["[[DEC-0069-settings-tab-rows-only-subpages]]"]
source: "https://github.com/Twin-Fang/passQL/issues/209"
---

# ISS-0116 완료 리포트: `/settings/feedback` 독립 라우트, SubpageLayout 추출

GitHub #209 작업 리포트 댓글 기준 (2026-04-13).

## 해결 방법
- `src/pages/SettingsFeedback.tsx`(신규): SubpageLayout + 오프라인 배너 + 기존 FeedbackForm·FeedbackList 재사용.
- `src/App.tsx`: `{ path: "settings/feedback", element: <SettingsFeedback /> }`를 AppLayout 밖에(탭바 없는 몰입형, QuestionDetail과 같은 구조).
- `src/pages/Settings.tsx`: FeedbackForm/List와 `useOnline`, `useMyFeedback`, `WifiOff` import 제거, 건의사항 섹션을 `SettingsRow` + `ChevronRight`로.
- `src/components/SubpageLayout.tsx`(신규): ArrowLeft 헤더 + 콘텐츠(`title`, `children`, `contentClassName`). DevPage도 전환.
- `SettingsRow.tsx`(코드리뷰 반영): `onClick`이 있으면 `<button type="button">`, 없으면 `<div>` — 키보드/스크린리더 접근, button-in-button 중첩 방지.
- `MobileHeader.tsx`: tokens.css에 없는 `bg-accent-light` → `bg-brand-light`, `hover:bg-indigo-100` → `hover:bg-brand-medium/20`.

## 근본 원인 (확정)
설정 탭이 기능 페이지를 겸한 구조. 부수 버그: `max-w-lg mx-auto` 수축(DevPage의 `py-6 px-4` 패턴으로 통일), 미정의 토큰 클래스 `bg-accent-light`로 원형 배경이 투명.

## 재발 방지
검증: 진입·뒤로가기, 오프라인 배너, 두 서브페이지 SubpageLayout, Tab 포커스·Enter, MobileHeader 원형 배경(`#EEF2FF`).

## 교훈
(원본에 없음, 볼트 정리) 배경이 투명하게 나오면 클래스가 tokens.css에 정의된 토큰인지부터 확인한다.
